import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/notification_model.dart';
import '../viewmodels/notifications_viewmodel.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationsViewModel vm = Get.put(NotificationsViewModel());
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            if (vm.unreadCount.value == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: vm.markAllSeen,
              child: const Text('Tout lire'),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.notifications.isEmpty) {
          return const DfEmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Aucune notification',
            subtitle: 'Vous êtes à jour.',
          );
        }
        return RefreshIndicator(
          onRefresh: vm.load,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: vm.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final AppNotification notif = vm.notifications[index];
              return _NotificationTile(
                notif: notif,
                primary: primary,
                onTap: () {
                  if (!notif.isSeen) vm.markSeen(notif.id);
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notif,
    required this.primary,
    required this.onTap,
  });

  final AppNotification notif;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: notif.isSeen
              ? DfColors.surface1(context)
              : DfColors.brandFaint(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: DfColors.borderColor(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: notif.isSeen
                    ? DfColors.surface2(context)
                    : DfColors.brandFaint(context),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.notifications_rounded,
                size: 18,
                color: notif.isSeen
                    ? DfColors.mutedTextColor(context)
                    : primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isSeen
                                ? FontWeight.w500
                                : FontWeight.w700,
                            fontSize: 14,
                            color: DfColors.textColor(context),
                          ),
                        ),
                      ),
                      if (!notif.isSeen)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notif.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    // Plain text only — no HTML rendering
                    Text(
                      notif.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: DfColors.mutedTextColor(context),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    notif.createdAt,
                    style: TextStyle(
                      fontSize: 11,
                      color: DfColors.dimTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
