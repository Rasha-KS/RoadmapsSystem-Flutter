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
      case ResourceType.youtube:
        return 'يوتيوب';
      case ResourceType.book:
        return 'كتاب';
    }
  }

  Future<void> _openLink(BuildContext context) async {
    final Uri? uri = Uri.tryParse(resource.link);
    if (uri == null) {
      return;
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent_1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _typeLabel,
                  style: AppTextStyles.smallText.copyWith(color: AppColors.text_1),
                ),
              ),
                const SizedBox(width: 10),
                Text(
            resource.title,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(color: AppColors.text_3),
          ),
            ],
          ),
 
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => _openLink(context),
            child: Text(
              resource.link,
              textAlign: TextAlign.right,
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.primary1,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
