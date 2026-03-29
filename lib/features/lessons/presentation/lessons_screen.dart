import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/app_primary_button.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/widgets/sub_lesson_card.dart';
import 'package:roadmaps/features/lessons/domain/lesson_entity.dart';
import 'package:roadmaps/features/lessons/presentation/lessons_provider.dart';

class LessonsScreen extends StatefulWidget {
  final int lessonId;
  final String roadmapTitle;
  final String lessonTitle;
  final String lessonDescription;
  final int lessonNumber;
  final bool isLessonCompleted;

  const LessonsScreen({
    super.key,
    required this.lessonId,
    this.roadmapTitle = '',
    this.lessonTitle = '',
    this.lessonDescription = '',
    this.lessonNumber = 1,
    this.isLessonCompleted = false,
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
      final provider = context.read<LessonsProvider>();
      if (provider.hasLoadedLesson(widget.lessonId)) {
        return;
      }
      provider.fetchLesson(
        lessonId: widget.lessonId,
        title: widget.lessonTitle,
        description: widget.lessonDescription,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonsProvider>();
    final lesson = provider.lesson;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 10),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.background,
              surfaceTintColor: AppColors.background,
              elevation: 0,
              titleSpacing: 16,
              title: Text(
                widget.roadmapTitle.isNotEmpty ? widget.roadmapTitle : 'المسار',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.text_5,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: provider.isCompleting
                      ? null
                      : () => Navigator.of(context).maybePop(false),
                  icon: const Icon(
                    Icons.arrow_right_alt_outlined,
                    size: 35,
                    color: AppColors.text_5,
                  ),
                  padding: const EdgeInsets.only(bottom: 5),
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ),
      body: PopScope(
        canPop: !provider.isCompleting,
        child: SafeArea(
          top: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 25),
                  child: _buildBody(provider, lesson),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LessonsProvider provider, LessonEntity? lesson) {
    if (provider.isLoading && lesson == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }

    if (lesson == null) {
      return _ErrorState(
        message: provider.errorMessage ?? 'تعذر تحميل الدرس.',
        onRetry: () {
          context.read<LessonsProvider>().fetchLesson(
                lessonId: widget.lessonId,
                title: widget.lessonTitle,
                description: widget.lessonDescription,
              );
        },
      );
    }

    return Column(
      children: [
        Container(
          width: 332,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.accent_3,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            lesson.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading5.copyWith(color: AppColors.text_3),
          ),
        ),
        const SizedBox(height: 14),
        if (provider.isLoading)
          const LinearProgressIndicator(
            color: AppColors.primary2,
            backgroundColor: AppColors.secondary2,
          ),
        if (provider.isLoading) const SizedBox(height: 12),
        Expanded(
          child: lesson.subLessons.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد دروس فرعية لهذا الدرس.',
                    style: AppTextStyles.body.copyWith(color: AppColors.text_1),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: lesson.subLessons.length,
                  itemBuilder: (context, index) {
                    final subLesson = lesson.subLessons[index];
                    final titleBase = 'درس ${widget.lessonNumber}-${subLesson.position}';
                    final title = subLesson.title.trim().isNotEmpty
                        ? '$titleBase (${subLesson.title.trim()})'
                        : titleBase;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SubLessonCard(
                        subLesson: subLesson,
                        displayTitle: title,
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 4),
        AppPrimaryButton(
          text: provider.isCompleting ? 'جاري الإنهاء...' : 'الدرس التالي',
          onPressed: provider.isCompleting
              ? null
              : () async {
                  if (widget.isLessonCompleted) {
                    showAppSnackBar(
                      ScaffoldMessenger.of(context),
                      message: 'هذا الدرس مكتمل بالفعل.',
                      variant: SnackBarVariant.warning,
                      duration: const Duration(milliseconds: 1000),
                    );
                    return;
                  }

                  final success =
                      await context.read<LessonsProvider>().completeLesson();
                  if (!mounted) return;
                  if (!success) {
                    showAppSnackBar(
                      ScaffoldMessenger.of(context),
                      message: provider.errorMessage ?? 'تعذر إنهاء الدرس.',
                      variant: SnackBarVariant.error,
                      duration: const Duration(milliseconds: 1000),
                    );
                    return;
                  }
                  Navigator.of(context).pop(true);
                },
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
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
              'إعادة المحاولة',
              style: AppTextStyles.boldSmallText.copyWith(
                color: AppColors.text_5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
