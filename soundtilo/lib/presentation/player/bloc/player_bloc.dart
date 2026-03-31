import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:soundtilo/core/debug/perf_trace.dart';
import 'package:soundtilo/domain/repository/track_repository.dart';
import 'package:soundtilo/domain/usecases/favorite_usecases.dart';
import 'package:soundtilo/domain/usecases/history_usecases.dart';
import 'package:soundtilo/presentation/player/bloc/player_event.dart';
import 'package:soundtilo/presentation/player/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  static const int _positionUpdateIntervalMs = 250;
  final AudioPlayer _audioPlayer;
  final TrackRepository _trackRepository;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final IsFavoriteUseCase _isFavoriteUseCase;
  final RecordListenUseCase _recordListenUseCase;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _playerErrorSub;
  int _lastPositionEventMs = -1;
  int _songsPlayedCount = 0;
  PlayerPlay? _pendingPlayEvent;
  bool isPremiumUser = false;

  PlayerBloc({
    required AudioPlayer audioPlayer,
    required TrackRepository trackRepository,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required IsFavoriteUseCase isFavoriteUseCase,
    required RecordListenUseCase recordListenUseCase,
  }) : _audioPlayer = audioPlayer,
        _trackRepository = trackRepository,
        _toggleFavoriteUseCase = toggleFavoriteUseCase,
        _isFavoriteUseCase = isFavoriteUseCase,
        _recordListenUseCase = recordListenUseCase,
        super(const PlayerState()) {
    on<PlayerPlay>(_onPlay, transformer: restartable());
    on<PlayerResume>(_onResume);
    on<PlayerPause>(_onPause);
    on<PlayerStop>(_onStop);
    on<PlayerNext>(_onNext);
    on<PlayerPrevious>(_onPrevious);
    on<PlayerSeek>(_onSeek);
    on<PlayerPositionChanged>(_onPositionChanged);
    on<PlayerDurationChanged>(_onDurationChanged);
    on<PlayerCompleted>(_onCompleted);
    on<PlayerToggleFavorite>(_onToggleFavorite);
    on<PlayerHideMiniPlayer>(_onHideMiniPlayer);
    on<PlayerShowMiniPlayer>(_onShowMiniPlayer);
    on<PlayerSourceError>(_onSourceError);
    on<PlayerAdFinished>(_onAdFinished); // Đăng ký event quảng cáo

    _positionSub = _audioPlayer.positionStream.listen((pos) {
      if (isClosed) return;
      final nextMs = pos.inMilliseconds;
      if (_lastPositionEventMs >= 0 &&
          (nextMs - _lastPositionEventMs).abs() < _positionUpdateIntervalMs) {
        return;
      }
      _lastPositionEventMs = nextMs;
      add(PlayerPositionChanged(pos));
    });

    _durationSub = _audioPlayer.durationStream.listen((dur) {
      if (dur != null) add(PlayerDurationChanged(dur));
    });

    _playerStateSub = _audioPlayer.processingStateStream.listen((procState) {
      if (procState == ProcessingState.completed) {
        add(PlayerCompleted());
      }
    });

    _playerErrorSub = _audioPlayer.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace _) {
        if (!isClosed) add(PlayerSourceError(error));
      },
    );
  }

  // CHỈ CÓ 1 HÀM _onPlay DUY NHẤT Ở ĐÂY
  Future<void> _onPlay(PlayerPlay event, Emitter<PlayerState> emit) async {
    // --- BẮT ĐẦU: LOGIC CHẶN QUẢNG CÁO ---
    // Chỉ đếm khi phát một bài hát mới hoàn toàn
    if (state.currentTrack?.externalId != event.track.externalId) {
      _songsPlayedCount++;

      // Nếu đã lướt qua bài thứ 5
      if (!isPremiumUser && _songsPlayedCount > 5 ) {
        _songsPlayedCount = 0; // Reset bộ đếm
        _pendingPlayEvent = event; // Cất bài hát này vào hàng chờ tạm
        await _audioPlayer.pause(); // Đảm bảo nhạc dừng hẳn
        emit(state.copyWith(isShowingAd: true)); // Báo cho UI biết để bật Ads
        return; // Dừng hàm _onPlay tại đây! Trả quyền về UI để bật Quảng cáo
      }
    }
    // --- KẾT THÚC: LOGIC QUẢNG CÁO ---

    // Record listening history immediately on click (fire-and-forget)
    unawaited(
      _recordListenUseCase(
        trackExternalId: event.track.externalId,
        durationListened: 0,
        completed: false,
      ),
    );

    // If same track is already playing/paused, just resume if paused and ensure unhidden
    if (state.currentTrack?.externalId == event.track.externalId) {
      emit(state.copyWith(isMiniPlayerHidden: false));
      if (state.status == PlayerStatus.paused) {
        add(PlayerResume());
      }
      return;
    }

    final stopwatch = Stopwatch()..start();
    int streamLookupMs = 0;
    int setSourceMs = 0;
    int favoriteCheckMs = 0;

    emit(
      state.copyWith(
        status: PlayerStatus.loading,
        currentTrack: event.track,
        queue: event.queue,
        currentIndex: event.startIndex,
        position: Duration.zero,
        duration: Duration.zero,
        isMiniPlayerHidden: false,
      ),
    );

    try {
      String? url = event.track.playableUrl;

      // Deezer preview URLs are time-limited CDN links. Always fetch a fresh
      // URL via the API — never use the cached URL from the track entity.
      if (url == null || url.isEmpty || event.track.source == 'deezer') {
        final streamLookupStopwatch = Stopwatch()..start();
        final result = await _trackRepository.getStreamUrl(
          event.track.externalId,
        );
        streamLookupStopwatch.stop();
        streamLookupMs = streamLookupStopwatch.elapsedMilliseconds;
        PerfTrace.slow(
          'player.play.streamLookup',
          streamLookupStopwatch,
          thresholdMs: 160,
          values: <String, Object?>{'trackId': event.track.externalId},
        );

        result.fold((err) {
          emit(state.copyWith(status: PlayerStatus.error, errorMessage: err));
          return;
        }, (streamUrl) => url = streamUrl);
      }

      if (url == null || url!.isEmpty) {
        emit(
          state.copyWith(
            status: PlayerStatus.error,
            errorMessage: 'Không tìm thấy link phát nhạc',
          ),
        );
        return;
      }

      final setSourceStopwatch = Stopwatch()..start();
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url!)));
      setSourceStopwatch.stop();
      setSourceMs = setSourceStopwatch.elapsedMilliseconds;
      PerfTrace.slow(
        'player.play.setSource',
        setSourceStopwatch,
        thresholdMs: 180,
        values: <String, Object?>{'trackId': event.track.externalId},
      );


      emit(state.copyWith(status: PlayerStatus.playing, isFavorite: false));
      unawaited(_audioPlayer.play());

      // Check favorite status
      final favoriteCheckStopwatch = Stopwatch()..start();
      final favResult = await _isFavoriteUseCase(event.track.externalId);
      favoriteCheckStopwatch.stop();
      favoriteCheckMs = favoriteCheckStopwatch.elapsedMilliseconds;
      PerfTrace.slow(
        'player.play.favoriteLookup',
        favoriteCheckStopwatch,
        thresholdMs: 160,
        values: <String, Object?>{'trackId': event.track.externalId},
      );

      favResult.fold((_) {}, (isFav) {
        final currentTrack = state.currentTrack;
        if (currentTrack?.externalId == event.track.externalId) {
          emit(state.copyWith(isFavorite: isFav));
        }
      });

    } catch (e) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: 'Lỗi phát nhạc: $e',
        ),
      );
    } finally {
      stopwatch.stop();
      PerfTrace.slow(
        'player.play',
        stopwatch,
        thresholdMs: 220,
        values: <String, Object?>{
          'queueLength': event.queue.length,
          'trackId': event.track.externalId,
          'streamLookupMs': streamLookupMs,
          'setSourceMs': setSourceMs,
          'favoriteCheckMs': favoriteCheckMs,
        },
      );
    }
  }

  Future<void> _onResume(PlayerResume event, Emitter<PlayerState> emit) async {
    final stopwatch = Stopwatch()..start();
    await _audioPlayer.play();
    emit(state.copyWith(status: PlayerStatus.playing));
    stopwatch.stop();
    PerfTrace.slow('player.resume', stopwatch, thresholdMs: 120);
  }

  Future<void> _onPause(PlayerPause event, Emitter<PlayerState> emit) async {
    final stopwatch = Stopwatch()..start();
    await _audioPlayer.pause();
    emit(state.copyWith(status: PlayerStatus.paused));
    stopwatch.stop();
    PerfTrace.slow('player.pause', stopwatch, thresholdMs: 120);
  }

  Future<void> _onStop(PlayerStop event, Emitter<PlayerState> emit) async {
    await _audioPlayer.stop();
    _lastPositionEventMs = -1;
    emit(
      const PlayerState(
        status: PlayerStatus.idle,
        position: Duration.zero,
        duration: Duration.zero,
        queue: [],
        currentIndex: 0,
        currentTrack: null,
        isFavorite: false,
        isShowingAd: false, // Reset cờ quảng cáo khi stop
      ),
    );
  }

  Future<void> _onNext(PlayerNext event, Emitter<PlayerState> emit) async {
    if (state.hasNext) {
      final nextIndex = state.currentIndex + 1;
      final nextTrack = state.queue[nextIndex];
      add(
        PlayerPlay(track: nextTrack, queue: state.queue, startIndex: nextIndex),
      );
    }
  }

  Future<void> _onPrevious(
      PlayerPrevious event,
      Emitter<PlayerState> emit,
      ) async {
    // If past 3 seconds, restart current track
    if (state.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      emit(state.copyWith(position: Duration.zero));
      return;
    }

    if (state.hasPrevious) {
      final prevIndex = state.currentIndex - 1;
      final prevTrack = state.queue[prevIndex];
      add(
        PlayerPlay(track: prevTrack, queue: state.queue, startIndex: prevIndex),
      );
    }
  }

  Future<void> _onSeek(PlayerSeek event, Emitter<PlayerState> emit) async {
    final stopwatch = Stopwatch()..start();
    await _audioPlayer.seek(event.position);
    _lastPositionEventMs = event.position.inMilliseconds;
    emit(state.copyWith(position: event.position));
    stopwatch.stop();
    PerfTrace.slow(
      'player.seek',
      stopwatch,
      thresholdMs: 120,
      values: <String, Object?>{'targetMs': event.position.inMilliseconds},
    );
  }

  void _onPositionChanged(
      PlayerPositionChanged event,
      Emitter<PlayerState> emit,
      ) {
    if (event.position == state.position) return;
    emit(state.copyWith(position: event.position));
  }

  void _onDurationChanged(
      PlayerDurationChanged event,
      Emitter<PlayerState> emit,
      ) {
    if (event.duration == state.duration) return;
    emit(state.copyWith(duration: event.duration));
  }

  Future<void> _onCompleted(
      PlayerCompleted event,
      Emitter<PlayerState> emit,
      ) async {
    // Auto-play next
    if (state.hasNext) {
      add(PlayerNext());
    } else {
      emit(
        state.copyWith(status: PlayerStatus.paused, position: Duration.zero),
      );
    }
  }

  Future<void> _onToggleFavorite(
      PlayerToggleFavorite event,
      Emitter<PlayerState> emit,
      ) async {
    if (state.currentTrack == null) return;
    final result = await _toggleFavoriteUseCase(state.currentTrack!.externalId);
    result.fold((_) {}, (isFav) => emit(state.copyWith(isFavorite: isFav)));
  }

  void _onHideMiniPlayer(PlayerHideMiniPlayer event, Emitter<PlayerState> emit) {
    emit(state.copyWith(isMiniPlayerHidden: true));
  }

  void _onShowMiniPlayer(PlayerShowMiniPlayer event, Emitter<PlayerState> emit) {
    emit(state.copyWith(isMiniPlayerHidden: false));
  }

  // --- HÀM XỬ LÝ SAU KHI XEM XONG QUẢNG CÁO ---
  Future<void> _onAdFinished(PlayerAdFinished event, Emitter<PlayerState> emit) async {
    emit(state.copyWith(isShowingAd: false)); // Tắt cờ quảng cáo
    if (_pendingPlayEvent != null) {
      add(_pendingPlayEvent!); // Bắn lại event phát bài hát đã bị cất tạm
      _pendingPlayEvent = null;
    }
  }

  void _onSourceError(
    PlayerSourceError event,
    Emitter<PlayerState> emit,
  ) {
    if (state.status == PlayerStatus.playing ||
        state.status == PlayerStatus.loading) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: 'Không thể phát bài hát này. Vui lòng thử lại.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _playerErrorSub?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
