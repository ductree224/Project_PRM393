import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/playlist_entity.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/library_event.dart';
import 'package:soundtilo/presentation/library/bloc/library_state.dart';
import 'package:soundtilo/presentation/library/pages/favorites.dart';
import 'package:soundtilo/presentation/library/pages/playlist_detail.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<LibraryBloc, LibraryState>(
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) {
              return true;
            }

            if (previous is LibraryLoaded && current is LibraryLoaded) {
              return previous.playlists != current.playlists ||
                  previous.favoriteTrackIds != current.favoriteTrackIds;
            }

            if (previous is LibraryRefreshing && current is LibraryRefreshing) {
              return previous.playlists != current.playlists ||
                  previous.favoriteTrackIds != current.favoriteTrackIds;
            }

            return false;
          },
          builder: (context, state) {
            if (state is LibraryLoading || state is LibraryInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LibraryError) {
              return Center(child: Text(state.message));
            }

            if (state is LibraryLoaded) {
              return _buildContent(context, state);
            }

            if (state is LibraryRefreshing) {
              return Stack(
                children: [
                  _buildContent(
                    context,
                    LibraryLoaded(
                      playlists: state.playlists,
                      favoriteTrackIds: state.favoriteTrackIds,
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlaylistDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LibraryLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Thư viện',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),

        // Favorites section
        SliverToBoxAdapter(
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, color: Colors.white),
            ),
            title: const Text(
              'Bài hát yêu thích',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${state.favoriteTrackIds.length} bài hát'),
            onTap: () {
              final libraryBloc = context.read<LibraryBloc>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: libraryBloc,
                    child: const FavoritesPage(),
                  ),
                ),
              );
            },
          ),
        ),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Playlist của bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        if (state.playlists.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.library_music_outlined,
                      size: 64,
                      color: AppColors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có playlist nào',
                      style: TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tạo playlist để lưu bài hát yêu thích',
                      style: TextStyle(color: AppColors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final playlist = state.playlists[index];
              return _PlaylistTile(playlist: playlist);
            }, childCount: state.playlists.length),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final libraryBloc = context.read<LibraryBloc>();
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => BlocProvider.value(
        value: libraryBloc,
        child: const _CreatePlaylistDialog(),
      ),
    );
  }
}

class _CreatePlaylistDialog extends StatefulWidget {
  const _CreatePlaylistDialog();

  @override
  State<_CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<_CreatePlaylistDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo playlist mới'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên playlist',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Mô tả (tuỳ chọn)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng nhập tên playlist.'),
                  backgroundColor: AppColors.errorColor,
                ),
              );
              return;
            }

            final description = _descriptionController.text.trim();
            context.read<LibraryBloc>().add(
              LibraryCreatePlaylist(
                name: name,
                description: description.isEmpty ? null : description,
              ),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Tạo'),
        ),
      ],
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final PlaylistEntity playlist;

  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50,
          height: 50,
          color: AppColors.grey.withValues(alpha: 0.3),
          child: const Icon(Icons.queue_music, color: AppColors.grey),
        ),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${playlist.trackCount} bài hát'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _showEditPlaylistDialog(context);
            return;
          }
          if (value == 'delete') {
            _showDeleteConfirm(context);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem<String>(value: 'edit', child: Text('Chỉnh sửa')),
          PopupMenuItem<String>(value: 'delete', child: Text('Xóa playlist')),
        ],
      ),
      onTap: () {
        final libraryBloc = context.read<LibraryBloc>();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: libraryBloc,
              child: PlaylistDetailPage(playlistId: playlist.id),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditPlaylistDialog(BuildContext context) async {
    final nameController = TextEditingController(text: playlist.name);
    final descriptionController = TextEditingController(
      text: playlist.description ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chỉnh sửa playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên playlist',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập tên playlist.'),
                      backgroundColor: AppColors.errorColor,
                    ),
                  );
                  return;
                }
                final description = descriptionController.text.trim();
                context.read<LibraryBloc>().add(
                  LibraryUpdatePlaylist(
                    playlistId: playlist.id,
                    name: name,
                    description: description.isEmpty ? null : description,
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
  }

  Future<void> _showDeleteConfirm(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa playlist?'),
          content: Text('Bạn có chắc chắn muốn xóa "${playlist.name}" không ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      context.read<LibraryBloc>().add(LibraryDeletePlaylist(playlist.id));
    }
  }
}
