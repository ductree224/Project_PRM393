import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';
import 'package:soundtilo/domain/usecases/admin_user_usecases.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_user_detail_bloc.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_user_detail_event.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_user_detail_state.dart';

class UserFavoritesDetailPage extends StatefulWidget {
  final AdminUserEntity user;

  const UserFavoritesDetailPage({super.key, required this.user});

  static Route<void> createRoute({required AdminUserEntity user}) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/admin/user-favorites-detail'),
      builder: (_) => UserFavoritesDetailPage(user: user),
    );
  }

  @override
  State<UserFavoritesDetailPage> createState() =>
      _UserFavoritesDetailPageState();
}

class _UserFavoritesDetailPageState extends State<UserFavoritesDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminUserDetailBloc>().add(const AdminUserDetailLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AdminUserDetailBloc(
            getAdminUserHistoryUseCase: sl<GetAdminUserHistoryUseCase>(),
            getAdminUserFavoritesUseCase: sl<GetAdminUserFavoritesUseCase>(),
            getAdminUserPlaylistsUseCase: sl<GetAdminUserPlaylistsUseCase>(),
          )..add(
            AdminUserDetailStarted(
              userId: widget.user.id,
              section: AdminUserDetailSection.favorites,
            ),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Favorites - ${widget.user.displayLabel}'),
          actions: [
            IconButton(
              onPressed: () => context.read<AdminUserDetailBloc>().add(
                const AdminUserDetailRefresh(),
              ),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<AdminUserDetailBloc, AdminUserDetailState>(
          builder: (context, state) {
            if (state.status == AdminUserDetailStatus.loading &&
                state.favorites.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == AdminUserDetailStatus.error &&
                state.favorites.isEmpty) {
              return _ErrorView(message: state.errorMessage);
            }

            if (state.favorites.isEmpty) {
              return const Center(
                child: Text('User chưa có bài hát yêu thích.'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminUserDetailBloc>().add(
                  const AdminUserDetailRefresh(),
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    state.favorites.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.favorites.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final item = state.favorites[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.14,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: Text(item.trackExternalId),
                    subtitle: Text(
                      'Thêm vào: ${item.createdAt.toLocal()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String? message;

  const _ErrorView({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? 'Không thể tải dữ liệu.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.errorColor),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<AdminUserDetailBloc>().add(
                const AdminUserDetailRefresh(),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
