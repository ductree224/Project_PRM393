import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/repositories/artist_repository.dart';
import '../../../../domain/repositories/album_repository.dart';
import '../bloc/artist_admin_bloc.dart';
import '../bloc/artist_admin_event.dart';
import '../bloc/artist_admin_state.dart';
import '../bloc/album_admin_bloc.dart';
import '../bloc/album_admin_event.dart';
import '../bloc/album_admin_state.dart';
import '../../../../data/models/artist_model.dart';
import '../../../../data/models/album_model.dart';
import '../widgets/artist_form_dialog.dart';
import '../widgets/album_form_dialog.dart';
import '../widgets/album_track_management_dialog.dart';

class AdminArtistsAlbumsPage extends StatelessWidget {
  const AdminArtistsAlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ArtistAdminBloc(repository: sl<ArtistRepository>())..add(const LoadArtists()),
        ),
        BlocProvider(
          create: (context) => AlbumAdminBloc(repository: sl<AlbumRepository>())..add(const LoadAlbums()),
        ),
      ],
      child: const _AdminArtistsAlbumsContent(),
    );
  }
}

class _AdminArtistsAlbumsContent extends StatelessWidget {
  const _AdminArtistsAlbumsContent();

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1100;

    return MultiBlocListener(
      listeners: [
        BlocListener<ArtistAdminBloc, ArtistAdminState>(
          listener: (context, state) {
            if (state is ArtistAdminOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            } else if (state is ArtistAdminError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
        ),
        BlocListener<AlbumAdminBloc, AlbumAdminState>(
          listener: (context, state) {
            if (state is AlbumAdminOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            } else if (state is AlbumAdminError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header Actions
          isDesktop ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildHeaderTitle(),
              _buildHeaderActions(context),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTitle(),
              const SizedBox(height: 24),
              _buildHeaderActions(context),
            ],
          ),
          const SizedBox(height: 32),
          // Main Content Tabs (Mocking a tab view with a single column for now)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildArtistsSection(context),
                ),
                if (isDesktop) const SizedBox(width: 32),
                if (isDesktop)
                  Expanded(
                    flex: 1,
                    child: _buildAlbumsSection(context),
                  ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildHeaderTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATALOG > ARTISTS & ALBUMS', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Artist & Album Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 4),
        Text('Curate and override global artist and album information', style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF61440C), foregroundColor: const Color(0xFFE5E2E1), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
          onPressed: () => _showArtistDialog(context),
          icon: const Icon(Icons.person_add),
          label: const Text('New Artist'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD79B), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          onPressed: () => _showAlbumDialog(context),
          icon: const Icon(Icons.album),
          label: const Text('New Album'),
        ),
      ],
    );
  }

  Widget _buildArtistsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Global Artists', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Expanded(
            child: BlocBuilder<ArtistAdminBloc, ArtistAdminState>(
              builder: (context, state) {
                if (state is ArtistAdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ArtistAdminLoaded) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2A2A).withValues(alpha: 0.5)),
                        columns: const [
                          DataColumn(label: Text('ARTIST', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                          DataColumn(label: Text('STATUS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                          DataColumn(label: Text('ALBUMS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                          DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                        ],
                        rows: state.artists.map((artist) => _buildArtistRow(context, artist)).toList(),
                      ),
                    ),
                  );
                }
                return const Center(child: Text('No artists found.', style: TextStyle(color: Colors.white)));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlbumsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Curated Albums', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Expanded(
            child: BlocBuilder<AlbumAdminBloc, AlbumAdminState>(
              builder: (context, state) {
                if (state is AlbumAdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AlbumAdminLoaded) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2A2A).withValues(alpha: 0.5)),
                        columns: const [
                          DataColumn(label: Text('ALBUM NAME', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                          DataColumn(label: Text('ARTIST', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                          DataColumn(label: Text('TAGS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                          DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                        ],
                        rows: state.albums.map((album) => _buildAlbumRow(context, album)).toList(),
                      ),
                    ),
                  );
                }
                return const Center(child: Text('No albums found.', style: TextStyle(color: Colors.white)));
              },
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildArtistRow(BuildContext context, ArtistModel artist) {
    final status = artist.isOverride ? 'Override' : 'Synced';
    final statusColor = artist.isOverride ? const Color(0xFFA4E7FF) : Colors.grey;
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            artist.imageUrl != null 
                ? CircleAvatar(radius: 16, backgroundImage: NetworkImage(artist.imageUrl!))
                : const CircleAvatar(radius: 16, backgroundColor: Color(0xFF353534), child: Icon(Icons.person, size: 16, color: Colors.white24)),
            const SizedBox(width: 12),
            Text(artist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        )),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        )),
        DataCell(const Text('-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.grey, size: 20), onPressed: () => _showArtistDialog(context, artist: artist)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () => _showDeleteConfirmDialog(context, 'artist', artist.id)),
          ],
        )),
      ],
    );
  }

  DataRow _buildAlbumRow(BuildContext context, AlbumModel album) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            album.coverImageUrl != null
                ? Container(width: 32, height: 32, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), image: DecorationImage(image: NetworkImage(album.coverImageUrl!), fit: BoxFit.cover)))
                : Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF353534), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.album, size: 16, color: Colors.white24)),
            const SizedBox(width: 12),
            Text(album.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        )),
        DataCell(Text(album.artist?.name ?? 'Unknown', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500))),
        DataCell(Row(
          children: album.tags.map((t) => Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF353534), borderRadius: BorderRadius.circular(4)),
            child: Text(t, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          )).toList(),
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.grey, size: 20), onPressed: () => _showAlbumDialog(context, album: album)),
            IconButton(icon: const Icon(Icons.queue_music, color: Colors.grey, size: 20), tooltip: 'Manage Tracks', onPressed: () => _showManageTracksDialog(context, album)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () => _showDeleteConfirmDialog(context, 'album', album.id)),
          ],
        )),
      ],
    );
  }

  void _showArtistDialog(BuildContext context, {ArtistModel? artist}) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ArtistAdminBloc>(),
        child: ArtistFormDialog(artist: artist),
      ),
    );
  }

  void _showAlbumDialog(BuildContext context, {AlbumModel? album}) {
    final artistState = context.read<ArtistAdminBloc>().state;
    final availableArtists = artistState is ArtistAdminLoaded ? artistState.artists : <ArtistModel>[];

    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AlbumAdminBloc>(),
        child: AlbumFormDialog(
          album: album,
          availableArtists: availableArtists,
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String type, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Delete $type?', style: const TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this item? This action cannot be undone.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (type == 'artist') {
                context.read<ArtistAdminBloc>().add(DeleteArtist(id));
              } else {
                context.read<AlbumAdminBloc>().add(DeleteAlbum(id));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManageTracksDialog(BuildContext context, AlbumModel album) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AlbumAdminBloc>(),
        child: AlbumTrackManagementDialog(album: album),
      ),
    );
  }
}

