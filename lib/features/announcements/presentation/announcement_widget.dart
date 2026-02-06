// features/announcements/presentation/announcement_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/announcement_entity.dart';
import 'announcements_provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class AnnouncementWidget extends StatefulWidget {
  const AnnouncementWidget({super.key});

  @override
  State<AnnouncementWidget> createState() => _AnnouncementWidgetState();
}

class _AnnouncementWidgetState extends State<AnnouncementWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementsProvider>().loadAnnouncements();
    });

    // Auto-slide every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final provider = context.read<AnnouncementsProvider>();
      if (provider.announcements.isEmpty) return;

      final nextPage = (_pageController.page?.toInt() ?? 0) + 1;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openLink(String? link) async {
    if (link == null) return;
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcements = context.watch<AnnouncementsProvider>().announcements;

    if (announcements.isEmpty) {
      return SizedBox(height: 100, child: _buildMotivationCard());
    }

    return Column(
      children: [
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: _pageController,
            reverse: true, // من اليمين لليسار
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index % announcements.length;
              });
            },
            itemBuilder: (context, index) {
              final item = announcements[index % announcements.length];
              return _buildAnnouncementCard(item);
            },
          ),
        ),
        const SizedBox(height: 6),
        // 🔹 Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(announcements.length, (i) => i).reversed
              .map(
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == i ? 8 : 6,
                  height: _currentIndex == i ? 8 : 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == i
                        ? AppColors.primary2
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // =======================
  // 🔔 كارد الإعلان
  // =======================
  Widget _buildAnnouncementCard(AnnouncementEntity item) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: screenWidth * 0.85, // أصغر قليلًا
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary2,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary1.withValues(alpha:0.7),
              offset: const Offset(1, 2),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            if (item.link != null)
              _ArrowButton(onTap: () => _openLink(item.link)),
            if (item.link != null) const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      item.title,
                      style: AppTextStyles.boldHeading5.copyWith(
                        color: AppColors.text_3,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        item.description,
                        style: AppTextStyles.boldSmallText.copyWith(
                          color: AppColors.text_4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================
  // 🌱 كارد تحفيزي (بدون زر)
  // =======================
  Widget _buildMotivationCard() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: screenWidth * 0.85,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondary2,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary1.withValues(alpha:0.7),
              offset: const Offset(2, 3),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '!ابدأ اليوم، مستقبلك البرمجي ينتظرك',
              style: AppTextStyles.boldHeading5.copyWith(
                color: AppColors.text_3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// =======================
// 🔘 زر سهم مخصص (Hover + Press + Shadow + Mouse Hand)
// =======================
class _ArrowButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ArrowButton({required this.onTap});

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.95 : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Color.alphaBlend(
                      Colors.black.withValues(alpha:0.05),
                      AppColors.primary2,
                    )
                  : AppColors.primary2,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary1.withValues(alpha:_isHovered ? 0.9 : 0.7),
                  offset: const Offset(1, 2),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              size: 18,
              color: _isHovered ? Colors.black87 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
