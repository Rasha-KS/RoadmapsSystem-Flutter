import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/lesson_card_2.dart';
import 'package:roadmaps/features/main_screen.dart';

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
  Widget build(BuildContext context) {
    final roadmapsProvider = context.watch<RoadmapsProvider>();
    final roadmaps = roadmapsProvider.roadmaps;

    return SafeArea(
      child: Scaffold(
        key: scaffoldkey,
        backgroundColor: AppColors.background,
        body: Center(
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
                    onPressed: () {},
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
                        delegate: SearchRoadmapsDelegate(roadmaps: roadmaps),
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
                  child: ListView(
                    children: [
                      ...roadmaps.map(
                        (course) => LessonCard2(
                          course: course,
                          widthMultiplier: 0.92,
                          trimLength: 70,
                          isEnrolled: roadmapsProvider.isCourseEnrolled(
                            course.id,
                          ),
                          onDelete: () {
                            showConfirmActionDialog(
                              context: context,
                              title: 'هل أنت متأكد من حذف المسار؟',
                              message: 'سوف يؤدي ذلك إلى إلغاء اشتراكك في المسار',
                              onConfirm: () async {
                                context
                                    .read<RoadmapsProvider>()
                                    .setCourseEnrollment(course.id, false);
                              },
                            );
                          },
                          onRefresh: () {
                            showConfirmActionDialog(
                              context: context,
                              title: 'هل أنت متأكد من إعادة المسار؟',
                              message:
                                  'سوف يؤدي ذلك إلى إعادتك لنقطة البداية في المسار',
                              onConfirm: () async {},
                            );
                          },
                          onEnrollmentChanged: (enrolled) {
                            context
                                .read<RoadmapsProvider>()
                                .setCourseEnrollment(course.id, enrolled);
                          },
                        ),
                      ),
                    ],
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
        actionsPadding: EdgeInsets.all(10),
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

        icon: Icon(
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
    return const SizedBox.shrink();
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
          final levels = ["محترف", "متوسط", "مبتدئ"];
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
                      // Text(
                      //   'المستوى',
                      //   textAlign: TextAlign.center,
                      //   style: AppTextStyles.body.copyWith(color: AppColors.text_4),
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(right: 10, left: 10),
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
                            title: 'هل أنت متأكد من حذف المسار؟',
                            message: 'سوف يؤدي ذلك إلى إلغاء اشتراكك في المسار',
                            onConfirm: () async {
                              context.read<RoadmapsProvider>().setCourseEnrollment(
                                course.id,
                                false,
                              );
                              setState(() {});
                            },
                          );
                        },
                        onRefresh: () {
                          showConfirmActionDialog(
                            context: context,
                            title: 'هل أنت متأكد من إعادة المسار؟',
                            message: 'سوف يؤدي ذلك إلى إعادتك لنقطة البداية في المسار',
                            onConfirm: () async {},
                          );
                        },
                        onEnrollmentChanged: (enrolled) {
                          context.read<RoadmapsProvider>().setCourseEnrollment(
                            course.id,
                            enrolled,
                          );
                          setState(() {});
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

