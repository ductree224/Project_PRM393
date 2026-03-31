import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/track_admin_repository.dart';
import 'track_admin_event.dart';
import 'track_admin_state.dart';
import '../../../data/models/track_admin_model.dart';
import '../../../data/models/track_model.dart';

class TrackAdminBloc extends Bloc<TrackAdminEvent, TrackAdminState> {
  final TrackAdminRepository repository;

  TrackAdminBloc({required this.repository}) : super(TrackAdminInitial()) {
    on<LoadTracks>(_onLoadTracks);
    on<UpdateTrackStatus>(_onUpdateTrackStatus);
    on<AddTracksToAlbum>(_onAddTracksToAlbum);
    on<FetchExternalTracks>(_onFetchExternalTracks);
    on<ImportTracks>(_onImportTracks);
  }

  Future<void> _onLoadTracks(LoadTracks event, Emitter<TrackAdminState> emit) async {
    emit(TrackAdminLoading());
    final result = await repository.getTracks(
      status: event.status,
      query: event.query,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (error) => emit(TrackAdminError(error)),
      (tracks) => emit(TrackAdminLoaded(
        tracks: tracks,
        currentStatus: event.status,
        currentQuery: event.query,
      )),
    );
  }

  Future<void> _onUpdateTrackStatus(UpdateTrackStatus event, Emitter<TrackAdminState> emit) async {
    final currentState = state;
    String? statusFilter;
    String? queryFilter;
    List<TrackAdminModel> tracks = [];
    if (currentState is TrackAdminLoaded) {
      statusFilter = currentState.currentStatus;
      queryFilter = currentState.currentQuery;
      tracks = currentState.tracks;
    } else if (currentState is TrackAdminOperationInProgress) {
      statusFilter = currentState.currentStatus;
      queryFilter = currentState.currentQuery;
      tracks = currentState.tracks;
    }

    emit(TrackAdminOperationInProgress(
      tracks: tracks,
      currentStatus: statusFilter,
      currentQuery: queryFilter,
    ));
    final result = await repository.updateTrackStatus(
      externalIds: event.externalIds,
      status: event.status,
    );

    result.fold(
      (error) => emit(TrackAdminError(error)),
      (_) {
        emit(TrackAdminOperationSuccess('Track status updated to ${event.status}'));
        add(LoadTracks(status: statusFilter, query: queryFilter));
      },
    );
  }

  Future<void> _onAddTracksToAlbum(AddTracksToAlbum event, Emitter<TrackAdminState> emit) async {
    final currentState = state;
    String? statusFilter;
    String? queryFilter;
    List<TrackAdminModel> tracks = [];
    if (currentState is TrackAdminLoaded) {
      statusFilter = currentState.currentStatus;
      queryFilter = currentState.currentQuery;
      tracks = currentState.tracks;
    } else if (currentState is TrackAdminOperationInProgress) {
      statusFilter = currentState.currentStatus;
      queryFilter = currentState.currentQuery;
      tracks = currentState.tracks;
    }

    emit(TrackAdminOperationInProgress(
      tracks: tracks,
      currentStatus: statusFilter,
      currentQuery: queryFilter,
    ));
    final result = await repository.addTracksToAlbum(
      albumId: event.albumId,
      trackIds: event.trackIds,
    );

    result.fold(
      (error) => emit(TrackAdminError(error)),
      (_) {
        emit(const TrackAdminOperationSuccess('Tracks added to album successfully'));
        add(LoadTracks(status: statusFilter, query: queryFilter));
      },
    );
  }

  Future<void> _onFetchExternalTracks(FetchExternalTracks event, Emitter<TrackAdminState> emit) async {
    final currentState = state;
    String? statusFilter;
    String? queryFilter;
    List<TrackAdminModel> tracks = [];
    if (currentState is TrackAdminLoaded) {
      statusFilter = currentState.currentStatus;
      queryFilter = currentState.currentQuery;
      tracks = currentState.tracks;
    } else if (currentState is TrackAdminOperationInProgress) {
      statusFilter = currentState.currentStatus;
      queryFilter = currentState.currentQuery;
      tracks = currentState.tracks;
    }

    emit(TrackAdminOperationInProgress(
      tracks: tracks,
      currentStatus: statusFilter,
      currentQuery: queryFilter,
    ));

    final result = await repository.fetchExternalTracks(
      query: event.query,
      source: event.source,
    );

    result.fold(
      (error) => emit(TrackAdminError(error)),
      (newTracks) => emit(TrackAdminDiscoveryLoaded(newTracks)),
    );
  }

  Future<void> _onImportTracks(ImportTracks event, Emitter<TrackAdminState> emit) async {
    final currentState = state;
    String? statusFilter;
    String? queryFilter;
    List<TrackAdminModel> tracks = [];
    if (currentState is TrackAdminLoaded) {
      statusFilter = currentState.currentStatus;
      queryFilter = currentState.currentQuery;
      tracks = currentState.tracks;
    } else if (currentState is TrackAdminOperationInProgress) {
      statusFilter = currentState.currentStatus;
      queryFilter = currentState.currentQuery;
      tracks = currentState.tracks;
    }

    emit(TrackAdminOperationInProgress(
      tracks: tracks,
      currentStatus: statusFilter,
      currentQuery: queryFilter,
    ));

    final result = await repository.importTracks(tracks: event.tracks);

    result.fold(
      (error) => emit(TrackAdminError(error)),
      (_) {
        emit(TrackAdminOperationSuccess('${event.tracks.length} tracks imported successfully.'));
        add(LoadTracks(status: statusFilter, query: queryFilter));
      },
    );
  }
}
