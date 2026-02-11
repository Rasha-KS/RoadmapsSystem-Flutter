import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

/// Builds a reusable custom Bottom Navigation Bar.
///
/// This bottom navigation bar:
/// - Displays navigation items with an icon and label.
/// - Highlights the selected item using a rounded background color.
/// - Uses smooth animated transitions when switching between items.
/// - Adjusts its size naturally based on content (responsive-friendly).
///
/// Parameters:
/// - [currentIndex] (required): Index of the currently selected navigation item.
/// - [onTap] (required): Callback triggered when a navigation item is tapped.
///
/// Returns:
/// - A [Widget] representing the customized bottom navigation bar.
Widget buildAppBottomNav({
  required int currentIndex,
  required ValueChanged<int> onTap,
}) {
  final List<Map<String, dynamic>> navItems = [
    {'icon': Icons.chat_bubble_outline, 'label': 'chatbot'},
    {'icon': Icons.people_outline, 'label': 'المجتمع'},
    {'icon': Icons.home_outlined, 'label': 'الرئيسية'},
    {'icon': Icons.person_outline, 'label': 'حسابي'},
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      // Define the bottom navigation bar height as a percentage of the available screen height 
      // This makes the bar responsive and adaptable across different device sizes
      final double navHeight = constraints.maxHeight * 0.12; 

      return Container(
        height: navHeight,
        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 4), // Vertical spacing from top and bottom
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(index),  // Call the callback when tapped
                child:FittedBox( 
                    fit: BoxFit.scaleDown,
                    // Ensures the icon and text shrink automatically if the available space is too small
                    // Prevents overflow and keeps the layout consistent on all screen sizes
                    child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),  // Smooth transition for background
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal:6, vertical:4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent_1 : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: 
                      Column(
                      mainAxisSize: MainAxisSize.min, // Only use space needed for icon + text
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size:29,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['label'] as String,
                          style: AppTextStyles.textNav.copyWith(
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    },
  );
}
