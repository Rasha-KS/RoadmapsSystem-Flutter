import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/lessons/domain/resource_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceTile extends StatelessWidget {
  final ResourceEntity resource;

  const ResourceTile({super.key, required this.resource});

  String get _typeLabel {
    switch (resource.type) {
      case ResourceType.article:
        return 'مقالة';
      case ResourceType.video:
        return 'فيديو';
      case ResourceType.book:
        return 'كتاب';
      case ResourceType.other:
        return 'مورد';
    }
  }

  Color get _typeColor {
    switch (resource.type) {
      case ResourceType.article:
        return AppColors.accent_1;
      case ResourceType.video:
        return AppColors.accent_3;
      case ResourceType.book:
        return AppColors.secondary2;
      case ResourceType.other:
        return AppColors.secondary1;
    }
  }

  Future<void> _openLink(BuildContext context) async {
    final Uri? uri = Uri.tryParse(resource.link);
    if (uri == null) return;

    final bool didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (didLaunch || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.backGroundError,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        content: Text(
          'تعذر فتح الرابط',
          textAlign: TextAlign.right,
          style: AppTextStyles.body.copyWith(color: AppColors.text_2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.secondary4,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openLink(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _typeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _typeLabel,
                        style: AppTextStyles.boldSmallText.copyWith(
                          color: AppColors.text_3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        resource.title,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text_3,
                        ),
                      ),
                    ),
                  ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  resource.link,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.smallText.copyWith(
                    color: AppColors.primary1,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
