import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import '../domain/notification_entity.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<NotificationsProvider>();
      if (provider.notifications.isEmpty) {
        provider.loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final hasInitialLoading =
        provider.state == NotificationsState.loading &&
        provider.notifications.isEmpty;
    final hasInitialError =
        provider.state == NotificationsState.connectionError &&
        provider.notifications.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              _ScreenHeader(
                onBackPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              Expanded(
                child: hasInitialLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary2,
                        ),
                      )
                    : hasInitialError
                    ? _ErrorState(
                        onRetry: () {
                          context
                              .read<NotificationsProvider>()
                              .loadNotifications();
                        },
                      )
                    : provider.notifications.isEmpty
                    ? const _EmptyState()
                    : _NotificationsList(notifications: provider.notifications),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const _ScreenHeader({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 10, top: 30, bottom: 25),

      child: Row(
        children: [
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'الإشعارات',
                textAlign: TextAlign.left,
                style: AppTextStyles.body.copyWith(color: AppColors.text_3),
              ),
            ),
          ),
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(
              Icons.arrow_forward,
              color: AppColors.text_5,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final List<NotificationEntity> notifications;

  const _NotificationsList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: notifications.length,
      separatorBuilder: (_, index) => Divider(
        height: 5,
        thickness: 1,
        color: AppColors.secondary1.withValues(alpha: 0.6),
      ),
      itemBuilder: (context, index) {
        return _NotificationTile(notification: notifications[index]);
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              _formatSchedule(notification.scheduledAt),
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.text_4,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text_4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification.message,
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.text_3,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: AppColors.primary2,
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'لا توجد أي إشعارات',
              style: AppTextStyles.boldSmallText.copyWith(
                color: AppColors.text_1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'تعذر تحميل الإشعارات',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                foregroundColor: AppColors.text_5,
                elevation: 0,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatSchedule(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}/$month/$day';
}
