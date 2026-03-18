import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/debug/perf_trace.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/presentation/search/bloc/search_event.dart';
import 'package:soundtilo/presentation/search/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchTracksUseCase _searchTracksUseCase;
  int _debounceGeneration = 0;
  int _latestRequestId = 0;

  SearchBloc({required SearchTracksUseCase searchTracksUseCase})
      : _searchTracksUseCase = searchTracksUseCase,
        super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchSubmitted>(_onSubmitted);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    final generation = ++_debounceGeneration;
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Ignore too-short queries to reduce noisy live calls.
    if (query.length < 2) {
      emit(SearchInitial());
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (generation != _debounceGeneration) {
      return;
    }

    await _performSearch(query, emit);
  }

  Future<void> _onSubmitted(
      SearchSubmitted event, Emitter<SearchState> emit) async {
    _debounceGeneration++;
    final query = event.query.trim();
    if (query.length < 2) {
      emit(SearchInitial());
      return;
    }

    await _performSearch(query, emit);
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    _debounceGeneration++;
    emit(SearchInitial());
  }

  Future<void> _performSearch(String query, Emitter<SearchState> emit) async {
    final stopwatch = Stopwatch()..start();
    final requestId = ++_latestRequestId;
    final shouldShowLoading = state is SearchInitial || state is SearchEmpty || state is SearchError;
    if (shouldShowLoading) {
      emit(SearchLoading());
    }

    final result = await _searchTracksUseCase(
      query,
      limit: 20,
      cacheOnly: true,
      fallbackExternal: false,
    );

    if (requestId != _latestRequestId) {
      return;
    }

    result.fold(
      (error) => emit(SearchError(error)),
      (tracks) {
        if (tracks.isEmpty) {
          emit(SearchEmpty(query));
        } else {
          emit(SearchLoaded(results: tracks, query: query));
        }
      },
    );

    stopwatch.stop();
    PerfTrace.slow(
      'search.query',
      stopwatch,
      thresholdMs: 150,
      values: <String, Object?>{
        'length': query.length,
        'requestId': requestId,
      },
    );
  }
}
