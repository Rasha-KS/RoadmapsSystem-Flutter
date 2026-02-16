import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// التنسيقات والألوان
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';
import 'package:roadmaps/core/widgets/lesson_card_2.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_screen.dart';

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
        final announcementsProvider = context.read<AnnouncementsProvider>();
        await homeProvider.loadHome();
        await announcementsProvider.loadAnnouncements();
      },
      color: AppColors.primary2,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
              const SizedBox(height: 15),
            const AnnouncementWidget(),
            const SizedBox(height: 12),
            Divider(color: AppColors.secondary2, thickness: 1, height: 2),
            const SizedBox(height: 12),
            _sectionHeader(
              "المسارات المقترحة",
              context,
              onButtonPressed: () =>   Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoadmapsScreen(),
                          ),
                        ),
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
              child: MaterialButton(
                onPressed: onButtonPressed,
                elevation:0,
                height: 27,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(23))),
                color: AppColors.accent_1,
                child: Text(
                  "عرض الكل",
                  style: AppTextStyles.boldSmallText.copyWith(
                    color: AppColors.text_4,
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
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.text_3,
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
            LessonCard2(course: course, widthMultiplier: 0.65, trimLength:40),
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
              widthMultiplier: 0.80,
              trimLength: 70,
              onDelete: () => print("حذف من القائمة الرئيسية"),
              onRefresh: () => print("تحديث القائمة الرئيسية"),
              onTap: () => print("فتح المسار"),
            ),
        ],
      ),
    );
  }

 Widget _buildEmptyState(Size size) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // الصورة
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              "assets/images/roadmap_empty_homepage.png",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 5),

        // السطر الأول من النص
        Padding(
          padding: const EdgeInsets.only(right: 32),
          child: Text(
            "هل انت مستعد",
            textAlign: TextAlign.right,
            style: AppTextStyles.heading2_2.copyWith(
              color: AppColors.text_1,
            ),
          ),
        ),
        // السطر الثاني (RichText)
      Padding(
  padding: const EdgeInsets.only(right: 35),
  child: Align(
    alignment: Alignment.centerRight,
    child: RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        style: AppTextStyles.heading2_2.copyWith(
          color: AppColors.text_1,
        ),
        children: [
          const TextSpan(text: "لأن تسلك "),
          TextSpan(
            text: "مسارك ",
            style: TextStyle(color: AppColors.primary2),
          ),
          const TextSpan(text: "الاول؟"),
        ],
      ),
    ),
  ),
)

      ],
    ),
  );
}
}
