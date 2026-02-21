import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/app_primary_button.dart';
import 'package:roadmaps/core/widgets/sub_lesson_card.dart';
import 'package:roadmaps/features/lessons/domain/lesson_entity.dart';
import 'package:roadmaps/features/lessons/presentation/lessons_provider.dart';

class LessonsScreen extends StatefulWidget {
  final String learningUnitId;
  final String roadmapTitle;

  const LessonsScreen({
    super.key,
    required this.learningUnitId,
    required this.roadmapTitle,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LessonsProvider>().fetchLesson(widget.learningUnitId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonsProvider>();
    final lesson = provider.lesson;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.background,
              surfaceTintColor: AppColors.background,
              elevation: 0,
              titleSpacing: 16,
              title: Text(
                widget.roadmapTitle,
                style: AppTextStyles.heading4.copyWith(color: AppColors.text_5),
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(false),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.text_5,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  child: lesson == null && provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary2,
                          ),
                        )
                      : _Content(
                          lesson: lesson,
                          isLoading: provider.isLoading,
                          onRetry: () {
                            context.read<LessonsProvider>().fetchLesson(
                              widget.learningUnitId,
                            );
                          },
                          onNextLesson: () => Navigator.of(context).pop(true),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final LessonEntity? lesson;
  final bool isLoading;
  final VoidCallback onRetry;
  final VoidCallback onNextLesson;

  const _Content({
    required this.lesson,
    required this.isLoading,
    required this.onRetry,
    required this.onNextLesson,
  });

  @override
  Widget build(BuildContext context) {
    if (lesson == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ' انفطع الاتصال لا توجد دروس للعرض اعد المحاولة  ',
              style: AppTextStyles.heading5.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                foregroundColor: AppColors.text_5,
                elevation: 0,
              ),
              onPressed: onRetry,
              child: Text(
                'إعادة المحاولة ',
                style: AppTextStyles.boldSmallText.copyWith(
                  color: AppColors.text_5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 332,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accent_3,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            lesson!.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading5.copyWith(color: AppColors.text_3),
          ),
        ),
        const SizedBox(height: 14),
        if (isLoading)
          const LinearProgressIndicator(
            color: AppColors.primary2,
            backgroundColor: AppColors.secondary2,
          ),
        if (isLoading) const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: lesson!.subLessons.length,
            itemBuilder: (context, index) {
              final subLesson = lesson!.subLessons[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SubLessonCard(subLesson: subLesson),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        AppPrimaryButton(
          text: 'الدرس التالي',
          onPressed: onNextLesson,
        ),
      ],
    );
  }
}
