import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/Colorapp.dart';

class NotificationQuickActions extends StatelessWidget {
  const NotificationQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      textDirection: TextDirection.rtl,
      children: [
        _buildActionBtn("mark_all_read".tr, Icons.done_all, isDark ? AppColor.primaryPurple.withOpacity(0.2) : const Color(0xFFEDE9FE), AppColor.primaryPurple),
        const SizedBox(width: 16),
        _buildActionBtn("delete_all".tr, Icons.delete_outline, isDark ? Colors.red.withOpacity(0.1) : const Color(0xFFFEE2E2), Colors.red),
      ],
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, )),
        ],
      ),
    );
  }
}
