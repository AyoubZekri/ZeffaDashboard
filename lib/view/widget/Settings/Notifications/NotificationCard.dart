import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/Colorapp.dart';
import '../../../../core/constant/AppTheme.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String desc;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.title,
    required this.desc,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isRead ? colors.cardColor : (isDark ? iconColor.withValues(alpha: 0.05) : iconColor.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRead ? colors.borderColor : iconColor.withValues(alpha: 0.3),
          width: isRead ? 1 : 1.5,
        ),
        boxShadow: isRead ? [] : [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isRead ? colors.inputFillColor : iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isRead ? Colors.grey : iconColor, size: 28),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                    const SizedBox(width: 12),
                    if (!isRead)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('unread_msg'.tr, style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.done_all, color: Colors.green, size: 12),
                            const SizedBox(width: 6),
                             Text('read_msg'.tr, style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(desc, style: TextStyle(fontSize: 14, color: isRead ? colors.subtitleColor : textColor.withValues(alpha: 0.8), height: 1.6, fontFamily: 'Cairo'), textAlign: TextAlign.right),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
