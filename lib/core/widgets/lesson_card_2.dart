import 'package:flutter/material.dart';
import 'package:see_more/see_more.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class LessonCard2 extends StatelessWidget {
  final dynamic course;
  final double widthMultiplier;
  final int trimLength;
  final VoidCallback? onEnroll;
  final bool? isEnrolled;
  final ValueChanged<bool>? onEnrollmentChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onRefresh;
  final VoidCallback? onTap;
  
  const LessonCard2({
    super.key,
    required this.course,
    required this.widthMultiplier,
    required this.trimLength,
    this.onEnroll,
    this.isEnrolled,
    this.onEnrollmentChanged,
    this.onDelete,
    this.onRefresh,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
              ],
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Align(alignment: AlignmentGeometry.centerRight,
              child: SeeMoreWidget(
                course.description,
                trimLength: trimLength,
                seeMoreText: '...المزيد',
                seeLessText: 'أقل',
                textStyle: AppTextStyles.body.copyWith(fontSize: 16,
                 color: AppColors.text_2,
                ),
                seeMoreStyle: AppTextStyles.smallText.copyWith(
                  color: AppColors.text_6,
                ),
                seeLessStyle: AppTextStyles.smallText.copyWith(
                  color: AppColors.text_6,
                ),
              ),
            ),
            const SizedBox(height:2),
            Row(
              children: [
                  MaterialButton(
                  color: AppColors.primary2,
                  minWidth: 70,
                  height: 25,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPressed: () {
                    if (widget.onEnrollmentChanged != null) {
                      widget.onEnrollmentChanged!(true);
                    } else {
                      setState(() => _isEnrolled = true);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:  Directionality(textDirection: TextDirection.rtl, child: Text(
                          "تم التسجيل بنجاح", style:  AppTextStyles.heading5.copyWith(color:AppColors.primary),
                        )),
                        backgroundColor: AppColors.backGroundSuccess,
                        duration: const Duration(seconds: 3),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                      ),
                      backgroundColor: AppColors.backGroundSuccess,
                      duration: const Duration(seconds: 3),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  'تسجيل',
                  style: AppTextStyles.boldSmallText.copyWith(
                    color: AppColors.text_5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent_2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.smallText.copyWith(
          color: AppColors.text_3,
        ),
      ),
    );
  }
}
