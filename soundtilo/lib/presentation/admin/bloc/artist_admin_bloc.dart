import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/artist_repository.dart';
import 'artist_admin_event.dart';
import 'artist_admin_state.dart';

class ArtistAdminBloc extends Bloc<ArtistAdminEvent, ArtistAdminState> {
  final ArtistRepository repository;

  ArtistAdminBloc({required this.repository}) : super(ArtistAdminInitial()) {
    on<LoadArtists>(_onLoadArtists);
    on<CreateArtist>(_onCreateArtist);
    on<UpdateArtist>(_onUpdateArtist);
    on<DeleteArtist>(_onDeleteArtist);
  }

  Future<void> _onLoadArtists(LoadArtists event, Emitter<ArtistAdminState> emit) async {
    emit(ArtistAdminLoading());
    final result = await repository.getArtists(tag: event.tag);
    result.fold(
      (error) => emit(ArtistAdminError(error)),
      (artists) => emit(ArtistAdminLoaded(artists)),
    );
  }

  Future<void> _onCreateArtist(CreateArtist event, Emitter<ArtistAdminState> emit) async {
    emit(ArtistAdminLoading());
    final result = await repository.createArtist(event.data);
    result.fold(
      (error) => emit(ArtistAdminError(error)),
      (_) {
        // Re-load artists after successful creation
        emit(const ArtistAdminOperationSuccess('Artist created successfully'));
        add(const LoadArtists());
      },
    );
  }

  Future<void> _onUpdateArtist(UpdateArtist event, Emitter<ArtistAdminState> emit) async {
    emit(ArtistAdminLoading());
    final result = await repository.updateArtist(event.id, event.data);
    result.fold(
      (error) => emit(ArtistAdminError(error)),
      (_) {
        emit(const ArtistAdminOperationSuccess('Artist updated successfully'));
        add(const LoadArtists());
      },
    );
  }

  Future<void> _onDeleteArtist(DeleteArtist event, Emitter<ArtistAdminState> emit) async {
    emit(ArtistAdminLoading());
    final result = await repository.deleteArtist(event.id);
    result.fold(
      (error) => emit(ArtistAdminError(error)),
      (_) {
        emit(const ArtistAdminOperationSuccess('Artist deleted successfully'));
        add(const LoadArtists());
      },
    );
  }
}
