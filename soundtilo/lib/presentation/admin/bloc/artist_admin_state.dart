import 'package:equatable/equatable.dart';
import '../../../../data/models/artist_model.dart';

abstract class ArtistAdminState extends Equatable {
  const ArtistAdminState();
  
  @override
  List<Object?> get props => [];
}

class ArtistAdminInitial extends ArtistAdminState {}

class ArtistAdminLoading extends ArtistAdminState {}

class ArtistAdminLoaded extends ArtistAdminState {
  final List<ArtistModel> artists;
  const ArtistAdminLoaded(this.artists);

  @override
  List<Object?> get props => [artists];
}

class ArtistAdminError extends ArtistAdminState {
  final String message;
  const ArtistAdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class ArtistAdminOperationSuccess extends ArtistAdminState {
  final String message;
  const ArtistAdminOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
