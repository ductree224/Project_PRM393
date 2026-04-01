import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/library_state.dart';
import 'package:soundtilo/presentation/library/pages/favorites.dart';
import 'package:soundtilo/presentation/library/pages/my_playlists_page.dart';
import 'package:soundtilo/presentation/library/pages/waitlist_page.dart';

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

        SliverToBoxAdapter(
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.queue_play_next, color: AppColors.primary),
            ),
            title: const Text(
              'Danh sách chờ phát',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Đang đợi phát tiếp theo'), // Nếu BLoC có số lượng bài hát thì truyền vào đây
            onTap: () {
              // Chuyển hướng sang màn hình Danh sách chờ
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WaitlistPage(), // Màn hình ta sẽ tạo ở Bước 2
                ),
              );
            },
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

        // Playlist section - single entry tile
        SliverToBoxAdapter(
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.library_music, color: AppColors.grey),
            ),
            title: const Text(
              'Playlist của bạn',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${state.playlists.length} playlist'),
            onTap: () {
              final libraryBloc = context.read<LibraryBloc>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: libraryBloc,
                    child: const MyPlaylistsPage(),
                  ),
                ),
              );
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
