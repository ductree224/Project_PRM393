import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/presentation/notifications/bloc/notification_cubit.dart';
import 'package:soundtilo/presentation/notifications/bloc/notification_state.dart';
import 'package:soundtilo/presentation/notifications/notification_view_tracker.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    NotificationViewTracker.isNotificationViewOpen.value = true;
  }

  @override
  void dispose() {
    NotificationViewTracker.isNotificationViewOpen.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thong bao'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () =>
                    context.read<NotificationCubit>().markAllAsRead(),
                child: const Text('Doc tat ca'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.items.isEmpty) {
            return Center(child: Text(state.error!));
          }

          if (state.items.isEmpty) {
            return const Center(child: Text('Chua co thong bao nao.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().refreshInbox(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Material(
                  color: item.isRead
                      ? Theme.of(context).cardColor
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: item.isRead
                        ? null
                        : () => context.read<NotificationCubit>().markAsRead(
                            item.id,
                          ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: item.isRead
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                      ),
                                ),
                              ),
                              if (!item.isRead)
                                const Icon(
                                  Icons.fiber_manual_record,
                                  size: 10,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item.message),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _Pill(label: item.typeLabel),
                              _Pill(
                                label: DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(item.createdAt),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
