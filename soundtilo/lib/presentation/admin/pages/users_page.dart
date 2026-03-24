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
  final ScrollController _tableScrollController = ScrollController();

  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _tableScrollController.addListener(_onTableScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tableScrollController
      ..removeListener(_onTableScroll)
      ..dispose();
    super.dispose();
  }

  void _onTableScroll() {
    if (!_tableScrollController.hasClients) {
      return;
    }

    final position = _tableScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      context.read<AdminUsersBloc>().add(const AdminUsersLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final showCompactAppBar = MediaQuery.of(context).size.width < 1024;

    return BlocProvider(
      create: (_) => AdminUsersBloc(
        getAdminUsersUseCase: sl<GetAdminUsersUseCase>(),
        banAdminUserUseCase: sl<BanAdminUserUseCase>(),
        unbanAdminUserUseCase: sl<UnbanAdminUserUseCase>(),
        changeAdminUserRoleUseCase: sl<ChangeAdminUserRoleUseCase>(),
        deleteAdminUserUseCase: sl<DeleteAdminUserUseCase>(),
      )..add(const AdminUsersStarted()),
      child: Scaffold(
        appBar: showCompactAppBar
            ? AppBar(
                title: const Text('User Management'),
                actions: [
                  IconButton(
                    onPressed: () => context.read<AdminUsersBloc>().add(
                      const AdminUsersRefresh(),
                    ),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              )
            : null,
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
            final selectedUser = _resolveSelectedUser(state);
            final screenWidth = MediaQuery.of(context).size.width;
            final isDesktop = screenWidth >= 1200;

            return Container(
              color: const Color(0xFF121212),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 24 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderSection(
                      total: state.total,
                      activeCount: state.users.where((u) => !u.isBanned).length,
                      bannedCount: state.users.where((u) => u.isBanned).length,
                    ),
                    const SizedBox(height: 18),
                    _FilterToolbar(
                      searchController: _searchController,
                      role: state.role,
                      isBanned: state.isBanned,
                      onSearchSubmitted: (query) => context
                          .read<AdminUsersBloc>()
                          .add(AdminUsersSearchChanged(query)),
                      onRoleChanged: (role) => context
                          .read<AdminUsersBloc>()
                          .add(AdminUsersRoleFilterChanged(role)),
                      onBanChanged: (value) => context
                          .read<AdminUsersBloc>()
                          .add(AdminUsersBanFilterChanged(value)),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildBody(
                        context: context,
                        state: state,
                        selectedUser: selectedUser,
                        screenWidth: screenWidth,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required AdminUsersState state,
    required AdminUserEntity? selectedUser,
    required double screenWidth,
  }) {
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 760 && screenWidth < 1200;

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
                state.errorMessage ?? 'Failed to load users.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorColor),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<AdminUsersBloc>().add(
                  const AdminUsersStarted(),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final tablePanel = _buildTablePanel(context, state, selectedUser);
    final detailPanel = _buildDetailPanel(context, selectedUser);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: tablePanel),
          const SizedBox(width: 16),
          Expanded(child: detailPanel),
        ],
      );
    }

    if (isTablet) {
      return Column(
        children: [
          Expanded(flex: 6, child: tablePanel),
          const SizedBox(height: 12),
          Expanded(flex: 4, child: detailPanel),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(height: 280, child: detailPanel),
        const SizedBox(height: 10),
        Expanded(child: tablePanel),
      ],
    );
  }

  Widget _buildTablePanel(
    BuildContext context,
    AdminUsersState state,
    AdminUserEntity? selectedUser,
  ) {
    final useCardList = MediaQuery.of(context).size.width < 980;

    return _PanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!useCardList)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'NAME',
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ROLE',
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'STATUS',
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'JOIN DATE',
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 44),
                ],
              ),
            ),
          const Divider(height: 1, color: Color(0xFF303030)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<AdminUsersBloc>().add(const AdminUsersRefresh());
              },
              child: ListView.builder(
                controller: _tableScrollController,
                itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.users.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final user = state.users[index];
                  final isSelected = selectedUser?.id == user.id;

                  if (useCardList) {
                    return _UserMobileCard(
                      user: user,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedUserId = user.id),
                      onBanToggle: () => _onBanToggle(context, user),
                      onRoleChange: () => _onRoleChange(context, user),
                      onDelete: () => _onDelete(context, user),
                      onViewDetail: () {
                        Navigator.push(
                          context,
                          UserPlaylistDetailPage.createRoute(user: user),
                        );
                      },
                    );
                  }

                  return _UserTableRow(
                    user: user,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedUserId = user.id),
                    onBanToggle: () => _onBanToggle(context, user),
                    onRoleChange: () => _onRoleChange(context, user),
                    onDelete: () => _onDelete(context, user),
                    onViewDetail: () {
                      Navigator.push(
                        context,
                        UserPlaylistDetailPage.createRoute(user: user),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(BuildContext context, AdminUserEntity? user) {
    final isCompact = MediaQuery.of(context).size.width < 560;
    final activeCount = context
        .read<AdminUsersBloc>()
        .state
        .users
        .where((u) => !u.isBanned)
        .length;
    final bannedCount = context
        .read<AdminUsersBloc>()
        .state
        .users
        .where((u) => u.isBanned)
        .length;

    return Column(
      children: [
        if (isCompact)
          Column(
            children: [
              _StatCard(
                title: 'Active Users',
                value: '$activeCount',
                accent: const Color(0xFFEAC07D),
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 10),
              _StatCard(
                title: 'Banned',
                value: '$bannedCount',
                accent: const Color(0xFFFF6B6B),
                icon: Icons.warning_amber_rounded,
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Active Users',
                  value: '$activeCount',
                  accent: const Color(0xFFEAC07D),
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Banned',
                  value: '$bannedCount',
                  accent: const Color(0xFFFF6B6B),
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        Expanded(
          child: _PanelShell(
            child: user == null
                ? const Center(
                    child: Text(
                      'Select a user to view details',
                      style: TextStyle(color: Color(0xFFAEAEAE)),
                    ),
                  )
                : _UserDetailContent(
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
                  ),
          ),
        ),
      ],
    );
  }

  AdminUserEntity? _resolveSelectedUser(AdminUsersState state) {
    if (state.users.isEmpty) {
      return null;
    }

    if (_selectedUserId != null) {
      for (final user in state.users) {
        if (user.id == _selectedUserId) {
          return user;
        }
      }
    }

    return state.users.first;
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
          title: const Text('Delete user?'),
          content: Text(
            'Are you sure you want to delete ${user.displayLabel}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
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
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => const _ReasonDialog(),
    );
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
              title: const Text('Change role'),
              content: DropdownButtonFormField<String>(
                value: selectedRole,
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, selectedRole),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final int total;
  final int activeCount;
  final int bannedCount;

  const _HeaderSection({
    required this.total,
    required this.activeCount,
    required this.bannedCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Review, monitor, and control platform members.',
              style: TextStyle(color: Color(0xFFB9B9B9), fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeaderPill(label: 'All: $total', selected: true),
                _HeaderPill(label: 'Active: $activeCount'),
                _HeaderPill(label: 'Banned: $bannedCount'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FilterToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String? role;
  final bool? isBanned;
  final ValueChanged<String> onSearchSubmitted;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<bool?> onBanChanged;

  const _FilterToolbar({
    required this.searchController,
    required this.role,
    required this.isBanned,
    required this.onSearchSubmitted,
    required this.onRoleChanged,
    required this.onBanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSearchSubmitted,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by username or email',
                      hintStyle: const TextStyle(color: Color(0xFF919191)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFB1B1B1),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            onSearchSubmitted(searchController.text),
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFFEAC07D),
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: role,
                        dropdownColor: const Color(0xFF252525),
                        decoration: _toolbarDecoration('Role'),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<bool?>(
                        value: isBanned,
                        dropdownColor: const Color(0xFF252525),
                        decoration: _toolbarDecoration('Status'),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('Any'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Active'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Banned'),
                          ),
                        ],
                        onChanged: onBanChanged,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 8,
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSearchSubmitted,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by username or email',
                    hintStyle: const TextStyle(color: Color(0xFF919191)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFB1B1B1),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => onSearchSubmitted(searchController.text),
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFFEAC07D),
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String?>(
                  value: role,
                  dropdownColor: const Color(0xFF252525),
                  decoration: _toolbarDecoration('Role'),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem<String?>(value: null, child: Text('All')),
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
                flex: 2,
                child: DropdownButtonFormField<bool?>(
                  value: isBanned,
                  dropdownColor: const Color(0xFF252525),
                  decoration: _toolbarDecoration('Status'),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem<bool?>(value: null, child: Text('Any')),
                    DropdownMenuItem<bool?>(
                      value: false,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem<bool?>(value: true, child: Text('Banned')),
                  ],
                  onChanged: onBanChanged,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _toolbarDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _UserTableRow extends StatelessWidget {
  final AdminUserEntity user;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onViewDetail;
  final VoidCallback onBanToggle;
  final VoidCallback onRoleChange;
  final VoidCallback onDelete;

  const _UserTableRow({
    required this.user,
    required this.isSelected,
    required this.onTap,
    required this.onViewDetail,
    required this.onBanToggle,
    required this.onRoleChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = user.role == 'admin'
        ? const Color(0xFFFFD79B)
        : const Color(0xFFEAC07D);
    final statusColor = user.isBanned
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF67D39A);

    return Material(
      color: isSelected ? const Color(0xFF2A2A2A) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF3A3A3A),
                      child: Text(
                        user.displayLabel.isNotEmpty
                            ? user.displayLabel[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFFFFD79B),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFA8A8A8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  user.role,
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        user.isBanned ? 'Banned' : 'Active',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: statusColor),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  _formatDate(user.createdAt),
                  style: const TextStyle(
                    color: Color(0xFFA8A8A8),
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFFBDBDBD)),
                  color: const Color(0xFF252525),
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        onViewDetail();
                        break;
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
                    const PopupMenuItem(
                      value: 'view',
                      child: Text(
                        'View details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'ban',
                      child: Text(
                        user.isBanned ? 'Unban user' : 'Ban user',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'role',
                      child: Text(
                        'Change role',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete user',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[value.month - 1]} ${value.day}, ${value.year}';
  }
}

class _UserMobileCard extends StatelessWidget {
  final AdminUserEntity user;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onViewDetail;
  final VoidCallback onBanToggle;
  final VoidCallback onRoleChange;
  final VoidCallback onDelete;

  const _UserMobileCard({
    required this.user,
    required this.isSelected,
    required this.onTap,
    required this.onViewDetail,
    required this.onBanToggle,
    required this.onRoleChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = user.role == 'admin'
        ? const Color(0xFFFFD79B)
        : const Color(0xFFEAC07D);
    final statusColor = user.isBanned
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF67D39A);

    return Card(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      color: isSelected ? const Color(0xFF2A2A2A) : const Color(0xFF232323),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF3A3A3A),
                    child: Text(
                      user.displayLabel.isNotEmpty
                          ? user.displayLabel[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFFFFD79B),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFA8A8A8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFFBDBDBD)),
                    color: const Color(0xFF252525),
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          onViewDetail();
                          break;
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
                      const PopupMenuItem(
                        value: 'view',
                        child: Text(
                          'View details',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'ban',
                        child: Text(
                          user.isBanned ? 'Unban user' : 'Ban user',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'role',
                        child: Text(
                          'Change role',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete user',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoTag(label: user.role, color: roleColor),
                  _InfoTag(
                    label: user.isBanned ? 'Banned' : 'Active',
                    color: statusColor,
                  ),
                  _InfoTag(
                    label: _UserTableRow._formatDate(user.createdAt),
                    color: const Color(0xFF9FA7B4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
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

class _UserDetailContent extends StatelessWidget {
  final AdminUserEntity user;
  final VoidCallback onViewDetail;
  final VoidCallback onBanToggle;
  final VoidCallback onRoleChange;
  final VoidCallback onDelete;

  const _UserDetailContent({
    required this.user,
    required this.onViewDetail,
    required this.onBanToggle,
    required this.onRoleChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = user.role == 'admin'
        ? const Color(0xFFFFD79B)
        : const Color(0xFFEAC07D);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFF373737),
              child: Text(
                user.displayLabel.isNotEmpty
                    ? user.displayLabel[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Color(0xFFFFD79B),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.displayLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(user.email, style: const TextStyle(color: Color(0xFFB4B4B4))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                user.role,
                style: TextStyle(color: roleColor, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: onBanToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.isBanned
                        ? const Color(0xFF67D39A)
                        : const Color(0xFFFFB86C),
                    foregroundColor: Colors.black,
                  ),
                  icon: Icon(user.isBanned ? Icons.lock_open : Icons.lock),
                  label: Text(user.isBanned ? 'Unban' : 'Ban'),
                ),
                OutlinedButton.icon(
                  onPressed: onRoleChange,
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Role'),
                ),
                OutlinedButton.icon(
                  onPressed: onViewDetail,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Details'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: Color(0xFF323232)),
            const SizedBox(height: 12),
            _DetailLine(label: 'User ID', value: user.id),
            _DetailLine(label: 'Username', value: user.username),
            _DetailLine(
              label: 'Status',
              value: user.isBanned ? 'Banned' : 'Active',
            ),
            _DetailLine(
              label: 'Banned Reason',
              value: user.bannedReason?.trim().isNotEmpty == true
                  ? user.bannedReason!
                  : '-',
            ),
            _DetailLine(
              label: 'Created',
              value: _UserTableRow._formatDate(user.createdAt),
            ),
            const SizedBox(height: 18),
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_forever, color: Color(0xFFFF6B6B)),
              label: const Text(
                'Delete user',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFA4A4A4),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, color: accent, size: 14),
              const SizedBox(width: 4),
              Text(
                'Live summary',
                style: TextStyle(color: accent, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF9D9D9D), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _PanelShell({
    required this.child,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: child,
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final bool selected;

  const _HeaderPill({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF353534) : const Color(0xFF262626),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFFFFD79B) : const Color(0xFFB0B0B0),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog();

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ban reason'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter reason (optional)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Ban'),
        ),
      ],
    );
  }
}
