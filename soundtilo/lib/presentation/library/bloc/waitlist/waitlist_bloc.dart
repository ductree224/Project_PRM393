import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
// Lưu ý: Thay đổi đường dẫn import này cho khớp với file UseCases thực tế của dự án
import 'package:soundtilo/domain/usecases/waitlist_usecases.dart';
import 'waitlist_event.dart';
import 'waitlist_state.dart';

class WaitlistBloc extends Bloc<WaitlistEvent, WaitlistState> {
  // Đã mở comment các UseCases để kết nối với API
  final GetWaitlistUseCase getWaitlistUseCase;
  final AddTrackToWaitlistUseCase addTrackToWaitlistUseCase;
  final RemoveTrackFromWaitlistUseCase removeTrackFromWaitlistUseCase;
  final ReorderWaitlistUseCase reorderWaitlistUseCase;

  WaitlistBloc({
    required this.getWaitlistUseCase,
    required this.addTrackToWaitlistUseCase,
    required this.removeTrackFromWaitlistUseCase,
    required this.reorderWaitlistUseCase,
  }) : super(WaitlistInitial()) {

    // Sự kiện 1: Tải toàn bộ danh sách chờ từ API
    on<WaitlistLoad>((event, emit) async {
      emit(WaitlistLoading());
      try {
        // Gọi API thật lấy dữ liệu
        final tracks = await getWaitlistUseCase.call();
        emit(WaitlistLoaded(tracks: tracks));
      } catch (e) {
        emit(const WaitlistError("Không thể tải danh sách chờ từ máy chủ."));
      }
    });

    // Sự kiện 2: Thêm 1 bài hát vào danh sách
    on<WaitlistAddTrack>((event, emit) async {
      try {
        // Gọi API ném bài hát lên Server
        await addTrackToWaitlistUseCase.call(event.trackExternalId);
        // Tải lại danh sách mới nhất sau khi thêm
        add(WaitlistLoad());
      } catch (e) {
        // Có thể bắn thêm Event báo lỗi qua UI nếu cần
      }
    });

    // Sự kiện 3: Xóa 1 bài hát (Optimistic Update)
    on<WaitlistRemoveTrack>((event, emit) async {
      if (state is WaitlistLoaded) {
        final currentState = state as WaitlistLoaded;

        // 1. Cập nhật UI ngay lập tức
        final newTracks = currentState.tracks
            .where((t) => t.externalId != event.trackExternalId)
            .toList();
        emit(WaitlistLoaded(tracks: newTracks));

        // 2. Chạy ngầm API xóa dưới Database
        try {
          await removeTrackFromWaitlistUseCase.call(event.trackExternalId);
        } catch (e) {
          // 3. Nếu API lỗi -> Hoàn tác lại danh sách cũ
          emit(currentState);
        }
      }
    });

    // Sự kiện 4: Kéo thả, sắp xếp lại (Optimistic Update)
    // Thay thế logic Reorder cũ bằng cái mới này:
    on<WaitlistReorderTracks>((event, emit) async {
      if (state is WaitlistLoaded) {
        final currentState = state as WaitlistLoaded;
        final currentTracks = currentState.tracks;

        final newTracks = <TrackEntity>[];
        for (var id in event.trackExternalIds) {
          final track = currentTracks.firstWhere((t) => t.externalId == id);
          newTracks.add(track);
        }

        // Cập nhật giao diện ngay lập tức với số lượng bài mờ mới
        emit(currentState.copyWith(tracks: newTracks, fadedCount: event.fadedCount));

        try { await reorderWaitlistUseCase.call(event.trackExternalIds); } catch (e) { emit(currentState); }
      }
    });

    // 1. LOGIC: Khi nghe xong 1 bài (Chuyển thành mờ)
    // LOGIC: Khi nghe xong 1 bài (Chuyển thành mờ)
    on<WaitlistMarkTrackAsPlayed>((event, emit) async {
      if (state is WaitlistLoaded) {
        final currentState = state as WaitlistLoaded;
        final tracks = List<TrackEntity>.from(currentState.tracks);

        // Tự động tìm chính xác vị trí bài vừa nghe xong
        final finishedIndex = tracks.indexWhere((t) => t.externalId == event.trackExternalId);

        if (finishedIndex != -1) {
          // Đẩy ranh giới bài mờ xuống dưới bài vừa nghe
          int newFadedCount = finishedIndex + 1;


          emit(currentState.copyWith(tracks: tracks, fadedCount: newFadedCount));
        }
      }
    });
    // LOGIC: Ấn phát 1 bài mới tinh -> Chèn vào vị trí Đang phát (Số 0)
    on<WaitlistInsertAndPlay>((event, emit) async {
      if (state is WaitlistLoaded) {
        final currentState = state as WaitlistLoaded;
        final tracks = List<TrackEntity>.from(currentState.tracks);
        int fadedCount = currentState.fadedCount;

        // Xóa bài này nếu nó đang lẩn khuất đâu đó trong danh sách (để bốc lên đầu)
        final oldIndex = tracks.indexWhere((t) => t.externalId == event.track.externalId);
        if (oldIndex != -1) {
          tracks.removeAt(oldIndex);
          if (oldIndex < fadedCount) fadedCount--; // Nếu lấy từ lịch sử lên, phải giảm lịch sử đi 1
        }

        // Chèn chễm chệ vào vị trí số 0 của Vùng Active
        tracks.insert(fadedCount, event.track);
        emit(currentState.copyWith(tracks: tracks, fadedCount: fadedCount));

        // Gọi API chạy ngầm để lưu lại
        try { await reorderWaitlistUseCase.call(tracks.map((t)=>t.externalId).toList()); } catch(e){}
      }
    });
    // 2. LOGIC: Đưa 1 bài hát lên đầu danh sách Active
    on<WaitlistMoveToTopActive>((event, emit) async {
      if (state is WaitlistLoaded) {
        final currentState = state as WaitlistLoaded;
        final tracks = List<TrackEntity>.from(currentState.tracks);
        int fadedCount = currentState.fadedCount;

        final oldIndex = tracks.indexWhere((t) => t.externalId == event.trackExternalId);
        if (oldIndex != -1) {
          final track = tracks.removeAt(oldIndex);

          // Nếu bài đó đang là bài mờ (Vuốt phải), thì số lượng bài mờ giảm đi 1
          if (oldIndex < fadedCount) fadedCount--;

          // Chèn vào đầu danh sách Active
          tracks.insert(fadedCount, track);

          emit(currentState.copyWith(tracks: tracks, fadedCount: fadedCount));

          // Lưu thứ tự mới xuống API
          final ids = tracks.map((t) => t.externalId).toList();
          try { await reorderWaitlistUseCase.call(ids); } catch(e){}
        }
      }
    });
  }
}