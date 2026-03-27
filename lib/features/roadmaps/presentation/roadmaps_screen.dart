import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/constants/ui_texts.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';
import 'package:roadmaps/core/widgets/lesson_card_2.dart';
import 'package:roadmaps/core/navigation/app_route_observer.dart';
import 'package:roadmaps/core/utils/enrollment_sync.dart';
import 'package:roadmaps/core/utils/page_refresh.dart';
import 'package:roadmaps/features/homepage/domain/home_entity.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_screen.dart';
import 'package:roadmaps/features/main_screen.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_provider.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_screen.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';

import '../domain/roadmap_entity.dart';
import 'roadmaps_provider.dart';

final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey();

HomeCourseEntity _toHomeCourse(RoadmapEntity course) {
  return HomeCourseEntity(
    id: course.id,
    title: course.title,
    level: course.level,
    description: course.description,
    status: course.status,
  );
}

Future<void> _openRoadmap(
  BuildContext context,
  RoadmapEntity course,
) async {
  final homeProvider = context.read<HomeProvider>();
  HomeCourseEntity details = _toHomeCourse(course);

  try {
    details = await homeProvider.fetchRoadmapDetails(course.id);
  } catch (_) {}

  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LearningPathScreen(
        roadmapId: course.id,
        roadmapTitle: details.title,
      ),
    ),
  );
}

Widget _buildRoadmapTile(
  BuildContext context,
  RoadmapEntity course, {
  required bool enrolled,
}) {
  final homeProvider = context.read<HomeProvider>();
  final roadmapsProvider = context.read<RoadmapsProvider>();
  final profileProvider = context.read<ProfileProvider>();
  final learningPathProvider = context.read<LearningPathProvider>();

  if (enrolled) {
    return LessonCard1(
      course: course,
      widthMultiplier: 0.92,
      trimLength: 70,
      onDelete: () async {
        try {
          await homeProvider.deleteCourse(
            course.id,
            courseData: _toHomeCourse(course),
            updateState: false,
          );
          await learningPathProvider.resetProgress(
            roadmapId: course.id,
            updateState: false,
          );
          homeProvider.removeCourseById(
            course.id,
            courseData: _toHomeCourse(course),
          );
          roadmapsProvider.setCourseEnrollment(course.id, false);
          if (!context.mounted) return;
          showActionSnackBar(
            ScaffoldMessenger.of(context),
            message: AppTexts.deleteSuccess,
            isSuccess: true,
          );

          unawaited(
            retryUntilSuccess(
              () => EnrollmentSync.refreshAll(
                homeProvider: homeProvider,
                roadmapsProvider: roadmapsProvider,
                profileProvider: profileProvider,
              ),
              label: 'RoadmapsScreen delete sync',
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          showActionSnackBar(
            ScaffoldMessenger.of(context),
            message: e is Exception ? AppTexts.deleteFailure : AppTexts.deleteFailure,
            isSuccess: false,
          );
        }
      },
      onRefresh: () async {
        try {
          await homeProvider.resetCourse(
            course.id,
            updateState: false,
          );
          await learningPathProvider.resetProgress(
            roadmapId: course.id,
            updateState: false,
          );
          homeProvider.resetCourseById(course.id);
          if (!context.mounted) return;
          showActionSnackBar(
            ScaffoldMessenger.of(context),
            message: AppTexts.resetSuccess,
            isSuccess: true,
          );

          unawaited(
            retryUntilSuccess(
              () => EnrollmentSync.refreshAll(
                homeProvider: homeProvider,
                roadmapsProvider: roadmapsProvider,
                profileProvider: profileProvider,
              ),
              label: 'RoadmapsScreen reset sync',
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          showActionSnackBar(
            ScaffoldMessenger.of(context),
            message: e is Exception ? AppTexts.resetFailure : AppTexts.resetFailure,
            isSuccess: false,
          );
        }
      },
      onTap: () async {
        await _openRoadmap(context, course);
      },
    );
  }

    return LessonCard2(
      course: course,
      widthMultiplier: 0.92,
      trimLength: 70,
      isEnrolled: false,
      onEnroll: () async {
        try {
          await homeProvider.enrollCourse(
            course.id,
            courseData: _toHomeCourse(course),
            updateState: true,
          );
          roadmapsProvider.setCourseEnrollment(course.id, true);
          if (!context.mounted) return;
          showActionSnackBar(
            ScaffoldMessenger.of(context),
            message: AppTexts.enrollSuccess,
            isSuccess: true,
          );

          unawaited(
            retryUntilSuccess(
              () => EnrollmentSync.refreshAll(
                homeProvider: homeProvider,
                roadmapsProvider: roadmapsProvider,
                profileProvider: profileProvider,
              ),
              label: 'RoadmapsScreen enroll sync',
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          showActionSnackBar(
            ScaffoldMessenger.of(context),
            message: e is Exception
                ? AppTexts.enrollFailure
                : AppTexts.enrollFailure,
            isSuccess: false,
          );
        }
      },
    onTap: () async {
      await _openRoadmap(context, course);
    },
  );
}

class RoadmapsScreen extends StatefulWidget {
  const RoadmapsScreen({super.key});

  @override
  State<RoadmapsScreen> createState() => _RoadmapsScreenState();
}

class _RoadmapsScreenState extends State<RoadmapsScreen> with RouteAware {
  PageRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _route) {
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      refreshRoadmapsPageData(context);
      context.read<NotificationsProvider>().loadUnreadCount();
    });
  }

  @override
  void didPopNext() {
    _refreshRoadmaps();
  }

  Future<void> _refreshRoadmaps() async {
    if (!mounted) return;
    final notificationsProvider = context.read<NotificationsProvider>();
    await refreshRoadmapsPageData(context);
    await notificationsProvider.loadUnreadCount();
  }

  @override
  void dispose() {
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roadmapsProvider = context.watch<RoadmapsProvider>();
    final homeProvider = context.watch<HomeProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final roadmaps = roadmapsProvider.roadmaps;
    final hasInitialLoading =
        roadmapsProvider.state == PageState.loading && roadmaps.isEmpty;
    final hasInitialError =
        (roadmapsProvider.state == PageState.connectionError &&
                roadmaps.isEmpty) ||
            (!homeProvider.hasLoadedHomeData && homeProvider.lastLoadFailed) ||
            (!profileProvider.hasLoadedProfileData &&
                profileProvider.lastLoadFailed);
    final isRefreshing =
        roadmapsProvider.state == PageState.loading && roadmaps.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final double rightPadding = screenWidth * 0.03;
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
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_none,
                              color: AppColors.text_5,
                              size: 25,
                            ),
                            if (context.watch<NotificationsProvider>().hasUnread)
                              Positioned(
                                right: -1,
                                top: -1,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                         padding: EdgeInsets.only(right: rightPadding, top: 1),
                        child: IconButton(
                          padding: const EdgeInsets.all(15),
                          onPressed: () {
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_right_alt_outlined,
                            color: AppColors.text_5,
                            size: 35,
                          ),
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
                      AppTexts.roadmapsBanner,
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
                          hintText: AppTexts.search,
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
                              message: roadmapsProvider.errorMessage ??
                                  AppTexts.roadmapsLoadError,
                              onRetry: () async {
                                await refreshRoadmapsPageData(context);
                              },
                            )
                          : RefreshIndicator(
                              color: AppColors.primary2,
                              onRefresh: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await refreshRoadmapsPageData(context);
                                if (roadmapsProvider.state == PageState.connectionError ||
                                    homeProvider.lastLoadFailed ||
                                    profileProvider.lastLoadFailed) {
                                  _showRefreshFailedSnackBar(
                                    messenger,
                                    message: AppTexts.roadmapsRefreshError,
                                  );
                                }
                              },
                              child: roadmaps.isEmpty
                                  ? ListView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      children: const [
                                        SizedBox(height: 110),
                                        _EmptyRoadmapsState(),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        ListView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          children: [
                                            ...roadmaps.map(
                                              (course) => _buildRoadmapTile(
                                                context,
                                                course,
                                                enrolled: roadmapsProvider
                                                    .isCourseEnrolled(course.id),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isRefreshing)
                                          Positioned.fill(
                                            child: IgnorePointer(
                                              child: Container(
                                                color: AppColors.background
                                                    .withValues(alpha: 0.35),
                                                child: const Center(
                                                  child: CircularProgressIndicator(
                                                    color: AppColors.primary2,
                                                  ),
                                                ),
                                              ),
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

  void _showRefreshFailedSnackBar(
    ScaffoldMessengerState messenger, {
    required String message,
  }) {
    messenger.showSnackBar(
      SnackBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        content: Text(
          'تعذر التحديث حالياً. تحقق من الشبكة وحاول مرة أخرى.',
          textAlign: TextAlign.right,
          style: AppTextStyles.body.copyWith(color: AppColors.text_2),
        ),
        backgroundColor: AppColors.backGroundError,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }
}

class _EmptyRoadmapsState extends StatelessWidget {
  const _EmptyRoadmapsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.route_outlined,
              size: 72,
              color: AppColors.primary1,
            ),
            const SizedBox(height: 18),
            Text(
              'لا يوجد مسارات لعرضها',
              style: AppTextStyles.heading4.copyWith(color: AppColors.text_5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

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
                message,
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
                AppTexts.retry,
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
          final levels = ['مبتدئ', 'متوسط', 'متقدم'];
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
                        text: AppTexts.all,
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
                                AppTexts.roadmapsNoResults,
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
                          children: filteredCourses
                              .map(
                                (course) => _buildRoadmapTile(
                                  context,
                                  course,
                                  enrolled:
                                      roadmapsProvider.isCourseEnrolled(course.id),
                                ),
                              )
                              .toList(),
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



