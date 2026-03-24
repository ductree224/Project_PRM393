import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/album_admin_bloc.dart';
import '../bloc/album_admin_event.dart';
import '../bloc/album_admin_state.dart';
import '../../../../data/models/album_model.dart';

class AlbumTrackManagementDialog extends StatelessWidget {
  final AlbumModel album;

  const AlbumTrackManagementDialog({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AlbumAdminBloc>()..add(LoadAlbumDetail(album.id)),
      child: AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            const Icon(Icons.queue_music, color: Color(0xFFFFD79B)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manage Tracks', style: const TextStyle(color: Colors.white, fontSize: 18)),
                  Text(album.title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 600,
          child: BlocBuilder<AlbumAdminBloc, AlbumAdminState>(
            builder: (context, state) {
              if (state is AlbumAdminLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AlbumAdminError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              }
              if (state is AlbumAdminDetailLoaded) {
                final tracks = state.album.tracks;
                if (tracks.isEmpty) {
                  return const Center(child: Text('No tracks in this album', style: TextStyle(color: Colors.grey)));
                }
                return ListView.separated(
                  itemCount: tracks.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final albumTrack = tracks[index];
                    final track = albumTrack.track;
                    return ListTile(
                      leading: Text('${albumTrack.position}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      title: Text(track?.title ?? 'Unknown Track', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(track?.artistName ?? 'Unknown Artist', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          context.read<AlbumAdminBloc>().add(RemoveTrackFromAlbum(
                                albumId: album.id,
                                trackExternalId: albumTrack.trackExternalId,
                              ));
                        },
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text('Unexpected state'));
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
