import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// التنسيقات والألوان
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';
import 'package:roadmaps/core/widgets/lesson_card_2.dart';

// Providers
import 'home_provider.dart';
import '../../announcements/presentation/announcements_provider.dart';
import '../../announcements/presentation/announcement_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final size = MediaQuery.of(context).size;

    if (homeProvider.state == HomeState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await homeProvider.loadHome();
        await context.read<AnnouncementsProvider>().loadAnnouncements();
      },
      color: AppColors.primary2,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const AnnouncementWidget(),
            const SizedBox(height: 12),
            Divider(color: AppColors.secondary2, thickness: 1, height: 2),
            const SizedBox(height: 12),
            _sectionHeader(
              "المسارات المقترحة",
              context,
              onButtonPressed: () => print("ضغطت على عرض المزيد"),
            ),
            const SizedBox(height: 3),
            // تمرير العرض هنا لضمان تناسق الكاردات
            _buildRecommendedSection(homeProvider.recommended),

            const SizedBox(height: 12),
            Divider(color: AppColors.secondary2, thickness: 1, height: 2),
            const SizedBox(height: 12),

           

            homeProvider.myCourses.isEmpty
                ? _buildEmptyState(size)
                : _sectionHeader("مساراتي", context),
            const SizedBox(height: 3), _buildMyCoursesList(homeProvider.myCourses),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
    String title,
    BuildContext context, {
    VoidCallback? onButtonPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final buttonHorizontalPadding = screenWidth * 0.04;
    final buttonVerticalPadding = screenHeight * 0.003;
    final buttonFontSize = screenHeight * 0.016;
    final titleFontSize = screenHeight * 0.03;
    final spaceBetween = screenWidth * 0.10;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.01,
      ),
      child: Row(
        children: [
          if (onButtonPressed != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: TextButton(
                onPressed: onButtonPressed,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent_1,
                  padding: EdgeInsets.symmetric(
                    horizontal: buttonHorizontalPadding,
                    vertical: buttonVerticalPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "عرض الكل",
                  style: AppTextStyles.boldSmallText.copyWith(
                    color: AppColors.text_4,
                    fontSize: buttonFontSize,
                  ),
                ),
              ),
            ),
          if (onButtonPressed != null) SizedBox(width: spaceBetween),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: AppTextStyles.boldHeading5.copyWith(
                  color: AppColors.text_3,
                  fontSize: titleFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(List courses) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (final course in courses)
            LessonCard2(course: course, widthMultiplier: 0.75),
        ],
      ),
    );
  }

  Widget _buildMyCoursesList(List courses) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (final course in courses)
            LessonCard1(
              course: course,
              widthMultiplier: 0.85,
              onDelete: () => print("حذف من القائمة الرئيسية"),
              onRefresh: () => print("تحديث القائمة الرئيسية"),
              onTap: () => print("فتح المسار"),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Padding(padding: EdgeInsets.all(15),
    child: Column(
      children: [
        Icon(
          Icons.polyline_rounded,
          size: size.width * 0.2,
          color: AppColors.text_1,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "هل انت مستعد لأن تسلك ",
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.text_1
              
            ),
            children: [
              TextSpan(
                text: "مسارك",
                style:AppTextStyles.heading4.copyWith(
                  color:AppColors.primary2, // البرتقالي
                )
              ),
              TextSpan(
                text: " الاول؟",
                style: AppTextStyles.heading4.copyWith(
                  color:AppColors.text_1
                ),
              ),
            ],
          ),
        ),
      ],
    ),) ;
  }
}
