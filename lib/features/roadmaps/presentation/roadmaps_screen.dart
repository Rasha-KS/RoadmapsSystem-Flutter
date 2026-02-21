import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/lesson_card_2.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_screen.dart';
import 'package:roadmaps/features/main_screen.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_screen.dart';

import '../domain/roadmap_entity.dart';
import 'roadmaps_provider.dart';

final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey();

class RoadmapsScreen extends StatefulWidget {
  const RoadmapsScreen({super.key});

  @override
  State<RoadmapsScreen> createState() => _RoadmapsScreenState();
}

class _RoadmapsScreenState extends State<RoadmapsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<RoadmapsProvider>();
      if (provider.roadmaps.isEmpty) {
        provider.loadRoadmaps();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final roadmapsProvider = context.watch<RoadmapsProvider>();
    final roadmaps = roadmapsProvider.roadmaps;
    final hasInitialLoading =
        roadmapsProvider.state == PageState.loading && roadmaps.isEmpty;
    final hasInitialError =
        roadmapsProvider.state == PageState.connectionError &&
        roadmaps.isEmpty;

    return Scaffold(
      key: scaffoldkey,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: const EdgeInsets.all(15),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.notifications_none,
                          color: AppColors.text_5,
                          size: 25,
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(15),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_right_alt_outlined,
                          color: AppColors.text_5,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent_1,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(15),
                    child: Text(
                      textAlign: TextAlign.right,
                      'هيا لنبدأ رحلتنا في  مسارٍ جديد',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.text_1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          showSearch(
                            context: context,
                            delegate: SearchRoadmapsDelegate(
                              roadmaps: roadmaps,
                            ),
                          );
                        },
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: const Icon(
                            Icons.search_outlined,
                            color: AppColors.text_1,
                          ),
                          hintText: 'البحث',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.text_1,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(184, 198, 209, 1),
                            ),
                          ),
                          fillColor: const Color.fromRGBO(233, 242, 248, 1),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(184, 198, 209, 1),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: hasInitialLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary2,
                              ),
                            )
                          : hasInitialError
                          ? _ErrorState(
                              onRetry: () async {
                                await context.read<RoadmapsProvider>().loadRoadmaps();
                              },
                            )
                          : RefreshIndicator(
                              color: AppColors.primary2,
                              onRefresh: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await context.read<RoadmapsProvider>().loadRoadmaps();
                                if (roadmapsProvider.state == PageState.connectionError) {
                                  _showRefreshFailedSnackBar(messenger);
                                }
                              },
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  ...roadmaps.map(
                                    (course) => LessonCard2(
                                      course: course,
                                      widthMultiplier: 0.92,
                                      trimLength: 70,
                                      isEnrolled: roadmapsProvider.isCourseEnrolled(course.id),
                                      onDelete: () {
                                        showConfirmActionDialog(
                                          context: context,
                                          title: 'هل أنت متأكد من حذف المسار؟',
                                          message:
                                              'سوف يؤدي ذلك إلى إلغاء اشتراكك في المسار',
                                          onConfirm: () async {
                                            final learningPathProvider =
                                                context.read<LearningPathProvider>();
                                            context
                                                .read<RoadmapsProvider>()
                                                .setCourseEnrollment(course.id, false);
                                            await learningPathProvider.resetProgress(
                                              roadmapId: course.id,
                                            );
                                          },
                                        );
                                      },
                                      onRefresh: () {
                                        showConfirmActionDialog(
                                          context: context,
                                          title: 'هل أنت متأكد من إعادة المسار؟',
                                          message:
                                              'سوف يؤدي ذلك إلى إعادتك لنقطة البداية في المسار',
                                          onConfirm: () async {
                                            await context
                                                .read<LearningPathProvider>()
                                                .resetProgress(roadmapId: course.id);
                                          },
                                        );
                                      },
                                      onEnrollmentChanged: (enrolled) {
                                        context
                                            .read<RoadmapsProvider>()
                                            .setCourseEnrollment(course.id, enrolled);
                                      },
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => LearningPathScreen(
                                              roadmapId: course.id,
                                              roadmapTitle: course.title,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRefreshFailedSnackBar(ScaffoldMessengerState messenger) {
    messenger.showSnackBar(
      SnackBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        content: Text(
          'تعذر التحديث بسبب انقطاع الاتصال بالشبكة',
          textAlign: TextAlign.right,
          style: AppTextStyles.body.copyWith(color: AppColors.text_2),
        ),
        backgroundColor: AppColors.backGroundError,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

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
                'تعذر تحميل المسارات',
                style: AppTextStyles.heading5.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                foregroundColor: AppColors.text_1,
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.boldSmallText.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class SearchRoadmapsDelegate extends SearchDelegate {
  final List<RoadmapEntity> roadmaps;
  String selectedLevel = '';

  SearchRoadmapsDelegate({required this.roadmaps});

  @override
  String get searchFieldLabel => '';

  @override
  TextStyle? get searchFieldStyle {
    return AppTextStyles.body.copyWith(color: AppColors.text_1);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: theme.appBarTheme.copyWith(
        actionsPadding: const EdgeInsets.all(10),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text_5),
      ),
      inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none)
          .copyWith(
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.text_4),
          ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(
          Icons.arrow_right_alt_outlined,
          size: 35,
          color: AppColors.text_1,
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        query = '';
      },
      icon: const Icon(Icons.close, size: 30, color: AppColors.text_1),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  List<RoadmapEntity> _allCourses() {
    return [...roadmaps];
  }

  List<RoadmapEntity> _filteredCourses(String level, String searchQuery) {
    var filtered = _allCourses();

    if (level.isNotEmpty) {
      filtered = filtered.where((course) => course.level == level).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (course) =>
                course.title.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StatefulBuilder(
        builder: (context, setState) {
          final roadmapsProvider = context.watch<RoadmapsProvider>();
          final levels = ['محترف', 'متوسط', 'مبتدئ'];
          final filteredCourses = _filteredCourses(selectedLevel, query);

          return Container(
            color: AppColors.background,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      ...levels.map(
                        (level) => _levelButton(
                          text: level,
                          active: selectedLevel == level,
                          onPressed: () =>
                              setState(() => selectedLevel = level),
                        ),
                      ),
                      _levelButton(
                        text: 'الكل',
                        active: selectedLevel.isEmpty,
                        onPressed: () => setState(() => selectedLevel = ''),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: query.trim().isNotEmpty && filteredCourses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off_outlined,
                                size: 64,
                                color: AppColors.primary2,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Ù„Ù… ÙŠØªÙ… Ø§Ù„Ø¹Ø«ÙˆØ± Ø¹Ù„Ù‰ Ø£ÙŠ Ù†ØªÙŠØ¬Ø©',
                                style: AppTextStyles.heading5.copyWith(
                                  color: AppColors.text_1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          children: filteredCourses.map((course) {
                            return LessonCard2(
                              course: course,
                              widthMultiplier: 0.92,
                              trimLength: 70,
                              isEnrolled: roadmapsProvider.isCourseEnrolled(
                                course.id,
                              ),
                              onDelete: () {
                                showConfirmActionDialog(
                                  context: context,
                                  title: 'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø­Ø°Ù Ø§Ù„Ù…Ø³Ø§Ø±ØŸ',
                                  message:
                                      'Ø³ÙˆÙ ÙŠØ¤Ø¯ÙŠ Ø°Ù„Ùƒ Ø¥Ù„Ù‰ Ø¥Ù„ØºØ§Ø¡ Ø§Ø´ØªØ±Ø§ÙƒÙƒ ÙÙŠ Ø§Ù„Ù…Ø³Ø§Ø±',
                                  onConfirm: () async {
                                    final learningPathProvider = context
                                        .read<LearningPathProvider>();
                                    context
                                        .read<RoadmapsProvider>()
                                        .setCourseEnrollment(course.id, false);
                                    await learningPathProvider.resetProgress(
                                      roadmapId: course.id,
                                    );
                                    setState(() {});
                                  },
                                );
                              },
                              onRefresh: () {
                                showConfirmActionDialog(
                                  context: context,
                                  title: 'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø³Ø§Ø±ØŸ',
                                  message:
                                      'Ø³ÙˆÙ ÙŠØ¤Ø¯ÙŠ Ø°Ù„Ùƒ Ø¥Ù„Ù‰ Ø¥Ø¹Ø§Ø¯ØªÙƒ Ù„Ù†Ù‚Ø·Ø© Ø§Ù„Ø¨Ø¯Ø§ÙŠØ© ÙÙŠ Ø§Ù„Ù…Ø³Ø§Ø±',
                                  onConfirm: () async {
                                    await context
                                        .read<LearningPathProvider>()
                                        .resetProgress(roadmapId: course.id);
                                  },
                                );
                              },
                              onEnrollmentChanged: (enrolled) {
                                context.read<RoadmapsProvider>().setCourseEnrollment(
                                  course.id,
                                  enrolled,
                                );
                                setState(() {});
                              },
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LearningPathScreen(
                                      roadmapId: course.id,
                                      roadmapTitle: course.title,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _levelButton({
    required String text,
    required bool active,
    required VoidCallback onPressed,
  }) {
    return MaterialButton(
      onPressed: onPressed,
      color: active ? AppColors.primary2 : AppColors.secondary2,
      height: 21,
      minWidth: 70,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Text(text, textAlign: TextAlign.center, style: AppTextStyles.body),
    );
  }
}

