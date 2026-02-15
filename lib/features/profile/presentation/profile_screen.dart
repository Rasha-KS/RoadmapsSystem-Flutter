import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';
import '../domain/user_roadmap_entity.dart';
import 'profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    if (provider.loading && provider.user == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadProfileData,
      color: AppColors.primary2,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        children: [
          _buildHeader(
            username: provider.user?.username ?? '',
            profileImageUrl: provider.user?.profileImageUrl,
          ),
          const SizedBox(height: 10),
          Divider(color: AppColors.secondary1, thickness: 1),
          const SizedBox(height: 12),
          ...provider.roadmaps.map((roadmap) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _RoadmapSection(roadmap: roadmap),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required String username,
    required String? profileImageUrl,
  }) {
    return Padding(padding: EdgeInsets.only(top: 20, right: 20, left: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
       
        Flexible(
          child: Text(
            username,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading4.copyWith(color: AppColors.text_1),
          ),
        ),

        const SizedBox(width:30),

         CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.accent_3,
          backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
              ? NetworkImage(profileImageUrl)
              : null,
          child: (profileImageUrl == null || profileImageUrl.isEmpty)
              ? Icon(Icons.person, color: AppColors.primary, size: 30)
              : null,
        ),
      ],
    ),
   );
  }
}

class _RoadmapSection extends StatelessWidget {
  final UserRoadmapEntity roadmap;

  const _RoadmapSection({required this.roadmap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LessonCard1(
          course: roadmap,
          widthMultiplier: 0.92,
          trimLength: 90,
          onDelete: () => showConfirmActionDialog(
            context: context,
            title: 'هل أنت متأكد من حذف المسار؟',
            message: 'سوف يؤدي ذلك إلى إلغاء اشتراكك في المسار',
            onConfirm: () async {
              await context.read<ProfileProvider>().deleteRoadmap(
                    roadmap.enrollmentId,
                  );
            },
          ),
          onRefresh: () => showConfirmActionDialog(
            context: context,
            title:'هل أنت متأكد من إعادة المسار؟',
            message:'سوف يؤدي ذلك إلى إعادتك لنقطة البداية في المسار',
            onConfirm: () async {
           await context.read<ProfileProvider>().resetRoadmap(
                roadmap.enrollmentId,
              );
            },
          ),
          onTap: () {},
        ),

        const SizedBox(height:10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
              child: _StatContainer(
                backgroundColor: AppColors.accent_1,
                text: 'نقاط الخبرة   ${roadmap.xpPoints}',
                icon: Icons.local_fire_department_outlined,
              ),
            ),

             const SizedBox(width: 10),

              Expanded(
                child: _StatContainer(
                  backgroundColor: AppColors.accent_3,
                  icon: Icons.av_timer_rounded,
                 text: '%نسبة التقدم  ${roadmap.progressPercentage}',

                ),
              ),
            
            ],
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: AppColors.secondary1, thickness: 1),
      ],
    );
  }

}

class _StatContainer extends StatelessWidget {
  final Color backgroundColor;
  final String text;
  final IconData icon;

  const _StatContainer({
    required this.backgroundColor,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:10 , vertical:5 ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween ,
        children: [
        Icon(icon, color: AppColors.primary2, size: 21),
        

        Text(
            text,
            style: AppTextStyles.body.copyWith(color: AppColors.text_1 , fontSize: 16),
        ),
          
        ],
      ),
    );
  }
}
