import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';
import 'package:soundtilo/domain/usecases/admin_user_usecases.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_users_bloc.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_users_event.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_users_state.dart';
import 'package:soundtilo/presentation/admin/pages/user_playlist_detail_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      context.read<AdminUsersBloc>().add(const AdminUsersLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminUsersBloc(
        getAdminUsersUseCase: sl<GetAdminUsersUseCase>(),
        banAdminUserUseCase: sl<BanAdminUserUseCase>(),
        unbanAdminUserUseCase: sl<UnbanAdminUserUseCase>(),
        changeAdminUserRoleUseCase: sl<ChangeAdminUserRoleUseCase>(),
        deleteAdminUserUseCase: sl<DeleteAdminUserUseCase>(),
      )..add(const AdminUsersStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quan ly Users'),
          actions: [
            IconButton(
              onPressed: () =>
                  context.read<AdminUsersBloc>().add(const AdminUsersRefresh()),
              icon: const Icon(Icons.refresh),
              tooltip: 'Lam moi',
            ),
          ],
        ),
        body: BlocConsumer<AdminUsersBloc, AdminUsersState>(
          listener: (context, state) {
            if (state.actionMessage != null &&
                state.actionMessage!.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.actionMessage!)));
            }
            if (state.errorMessage != null &&
                state.errorMessage!.isNotEmpty &&
                state.status != AdminUsersStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _FilterBar(
                  searchController: _searchController,
                  role: state.role,
                  isBanned: state.isBanned,
                  onSearchSubmitted: (query) => context
                      .read<AdminUsersBloc>()
                      .add(AdminUsersSearchChanged(query)),
                  onRoleChanged: (role) => context.read<AdminUsersBloc>().add(
                    AdminUsersRoleFilterChanged(role),
                  ),
                  onBanChanged: (isBanned) => context
                      .read<AdminUsersBloc>()
                      .add(AdminUsersBanFilterChanged(isBanned)),
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminUsersState state) {
    if (state.status == AdminUsersStatus.loading && state.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AdminUsersStatus.error && state.users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Khong the tai danh sach user.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorColor),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<AdminUsersBloc>().add(
                  const AdminUsersStarted(),
                ),
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.users.isEmpty) {
      return const Center(
        child: Text('Khong co user phu hop bo loc hien tai.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminUsersBloc>().add(const AdminUsersRefresh());
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.users.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final user = state.users[index];
          return _UserCard(
            user: user,
            onViewDetail: () {
              Navigator.push(
                context,
                UserPlaylistDetailPage.createRoute(user: user),
              );
            },
            onBanToggle: () => _onBanToggle(context, user),
            onRoleChange: () => _onRoleChange(context, user),
            onDelete: () => _onDelete(context, user),
          );
        },
      ),
    );
  }

  Future<void> _onBanToggle(BuildContext context, AdminUserEntity user) async {
    if (!user.isBanned) {
      final reason = await _showReasonDialog(context);
      if (reason == null) {
        return;
      }
      if (!context.mounted) {
        return;
      }
      context.read<AdminUsersBloc>().add(
        AdminUsersBanToggleRequested(
          userId: user.id,
          isCurrentlyBanned: user.isBanned,
          reason: reason,
        ),
      );
      return;
    }

    context.read<AdminUsersBloc>().add(
      AdminUsersBanToggleRequested(
        userId: user.id,
        isCurrentlyBanned: user.isBanned,
      ),
    );
  }

  Future<void> _onRoleChange(BuildContext context, AdminUserEntity user) async {
    final role = await _showRoleDialog(context, currentRole: user.role);
    if (role == null || !context.mounted) {
      return;
    }
    context.read<AdminUsersBloc>().add(
      AdminUsersRoleChangeRequested(userId: user.id, newRole: role),
    );
  }

  Future<void> _onDelete(BuildContext context, AdminUserEntity user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xoa user?'),
          content: Text('Ban chac chan muon xoa ${user.displayLabel}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Huy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Xoa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    context.read<AdminUsersBloc>().add(AdminUsersDeleteRequested(user.id));
  }

  Future<String?> _showReasonDialog(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ly do khoa tai khoan'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Nhap ly do (co the de trong)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Huy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Khoa'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return reason;
  }

  Future<String?> _showRoleDialog(
    BuildContext context, {
    required String currentRole,
  }) async {
    var selectedRole = currentRole;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Doi role'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('user')),
                  DropdownMenuItem(value: 'admin', child: Text('admin')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => selectedRole = value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Huy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, selectedRole),
                  child: const Text('Luu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? role;
  final bool? isBanned;
  final ValueChanged<String> onSearchSubmitted;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<bool?> onBanChanged;

  const _FilterBar({
    required this.searchController,
    required this.role,
    required this.isBanned,
    required this.onSearchSubmitted,
    required this.onRoleChanged,
    required this.onBanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.16)),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: onSearchSubmitted,
            decoration: InputDecoration(
              hintText: 'Tim theo ten hoac email',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () => onSearchSubmitted(searchController.text),
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tat ca'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'user',
                      child: Text('user'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'admin',
                      child: Text('admin'),
                    ),
                  ],
                  onChanged: onRoleChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<bool?>(
                  initialValue: isBanned,
                  decoration: const InputDecoration(
                    labelText: 'Trang thai ban',
                  ),
                  items: const [
                    DropdownMenuItem<bool?>(value: null, child: Text('Tat ca')),
                    DropdownMenuItem<bool?>(value: true, child: Text('Da ban')),
                    DropdownMenuItem<bool?>(
                      value: false,
                      child: Text('Hoat dong'),
                    ),
                  ],
                  onChanged: onBanChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUserEntity user;
  final VoidCallback onViewDetail;
  final VoidCallback onBanToggle;
  final VoidCallback onRoleChange;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onViewDetail,
    required this.onBanToggle,
    required this.onRoleChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    user.displayLabel.isNotEmpty
                        ? user.displayLabel[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'ban':
                        onBanToggle();
                        break;
                      case 'role':
                        onRoleChange();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'ban',
                      child: Text(user.isBanned ? 'Unban user' : 'Ban user'),
                    ),
                    const PopupMenuItem(value: 'role', child: Text('Doi role')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xoa user'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: 'Role: ${user.role}',
                  color: user.role == 'admin'
                      ? AppColors.secondary
                      : AppColors.primary,
                ),
                _InfoChip(
                  label: user.isBanned ? 'Da ban' : 'Dang hoat dong',
                  color: user.isBanned
                      ? AppColors.errorColor
                      : AppColors.successColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onViewDetail,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Xem chi tiet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
