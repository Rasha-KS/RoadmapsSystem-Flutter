import 'package:flutter/material.dart';
import 'package:see_more/see_more.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';

class LessonCard2 extends StatefulWidget {
  final dynamic course;
  final double widthMultiplier;
  final int trimLength;
  final bool? isEnrolled;
  final ValueChanged<bool>? onEnrollmentChanged;
   final VoidCallback? onEnroll;
  final VoidCallback? onDelete;
  final VoidCallback? onRefresh;
  final VoidCallback? onTap;

  const LessonCard2({
    super.key,
    required this.course,
    required this.widthMultiplier,
    required this.trimLength,
    this.isEnrolled,
    this.onEnrollmentChanged,
     this.onEnroll,
    this.onDelete,
    this.onRefresh,
    this.onTap,
  });

  @override
  State<LessonCard2> createState() => _LessonCard2State();
}

class _LessonCard2State extends State<LessonCard2>
    with SingleTickerProviderStateMixin {
  bool _isEnrolled = false;

  @override
  Widget build(BuildContext context) {
    final isEnrolled = widget.isEnrolled ?? _isEnrolled;

    if (isEnrolled) {
      return LessonCard1(
        trimLength:70 ,
        course: widget.course,
        widthMultiplier: 0.80,
        onDelete: () {
          if (widget.onEnrollmentChanged != null) {
            widget.onEnrollmentChanged!(false);
          } else {
            setState(() => _isEnrolled = false);
          }
          widget.onDelete?.call();
        },
        onRefresh: widget.onRefresh ?? () {},
        onTap: widget.onTap ?? () {},
      );
    }

    final width = MediaQuery.of(context).size.width * widget.widthMultiplier;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 130),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12 , horizontal: 22),
        decoration: BoxDecoration(
          color: AppColors.primary1,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(12, 32, 49, 0.25),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(widget.course.level),
                Expanded(
                  child: Text(
                    widget.course.title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.text_2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Align(alignment: AlignmentGeometry.centerRight,
              child: SeeMoreWidget(
                widget.course.description,
                trimLength: widget.trimLength,
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
              )
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
                    );
                  },
                  child: Text(
                    "تسجيل",
                    style:AppTextStyles.boldSmallText.copyWith(
                     color: AppColors.text_5,
                    )
                  ),
              
                )
              ],
            )
            ],),
        ),
      );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:11 , vertical:2 ),
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
