import 'package:equatable/equatable.dart';

abstract class ArtistAdminEvent extends Equatable {
  const ArtistAdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadArtists extends ArtistAdminEvent {
  final String? tag;
  const LoadArtists({this.tag});

  @override
  List<Object?> get props => [tag];
}

class CreateArtist extends ArtistAdminEvent {
  final Map<String, dynamic> data;
  const CreateArtist(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateArtist extends ArtistAdminEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateArtist(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteArtist extends ArtistAdminEvent {
  final String id;
  const DeleteArtist(this.id);

  @override
  List<Object?> get props => [id];
}
