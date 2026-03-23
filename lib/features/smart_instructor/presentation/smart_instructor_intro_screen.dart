import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class SmartInstructorIntroScreen extends StatelessWidget {
  const SmartInstructorIntroScreen({super.key, required this.onStartPressed});

  final Future<void> Function() onStartPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                const Spacer(flex: 3),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.secondary4,
                        AppColors.accent_3,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppColors.secondary1),
                  ),
                  child: Center(
                    child: Image.asset("assets/images/smart_instructor.png") ),
                ),
                const SizedBox(height: 28),
                Text(
                  'مرحبًا بك في المعلم الذكي',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.text_3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'اكتب سؤالك، وسأجد لك الإجابة، كيف يمكنني مساعدتك؟',
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.text_1,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(flex: 4),
                SizedBox(
                  width: 230,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      await onStartPressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary2,
                      foregroundColor: AppColors.text_1,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'هيا لنبدأ',
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.text_3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 55),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
