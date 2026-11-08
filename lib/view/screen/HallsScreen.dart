import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/HallsController.dart';
import '../../core/constant/AppTheme.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/functions/dialogDelete.dart';
import '../../data/model/HallModel.dart';
import '../widget/halls/HallFormDialog.dart';

class HallsScreen extends StatelessWidget {
  const HallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';

    Get.delete<HallsController>();
    final ctrl = Get.put(HallsController());

    void openAddDialog() {
      ctrl.clearForm();
      Get.dialog(const HallFormDialog(), barrierDismissible: true);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            int crossAxisCount = 4;
            if (constraints.maxWidth < 600) {
              crossAxisCount = 1;
            } else if (constraints.maxWidth < 900) {
              crossAxisCount = 2;
            } else if (constraints.maxWidth < 1300) {
              crossAxisCount = 3;
            }

            return Container(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: GetBuilder<HallsController>(
                builder: (controller) {
                  final halls = controller.allHalls;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme, colors, isMobile, openAddDialog),
                      SizedBox(height: isMobile ? 20 : 32),
                      // All cards have the same size
                      Expanded(
                        child: GridView.builder(
                          itemCount: halls.length,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: isMobile ? 16 : 24,
                                mainAxisExtent: 290,
                              ),
                          itemBuilder: (context, index) =>
                              _buildHallCard(ctrl, halls[index], theme, colors),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Header: title + description + add button (same as the other pages)
  // ═══════════════════════════════════════
  Widget _buildHeader(
    ThemeData theme,
    AppColors colors,
    bool isMobile,
    VoidCallback onAdd,
  ) {
    final title = Text(
      'halls'.tr,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );

    final addButton = ElevatedButton.icon(
      onPressed: onAdd,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(
        'add_hall'.tr,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: addButton),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: title),
        const SizedBox(width: 16),
        addButton,
      ],
    );
  }

  // ═══════════════════════════════════════
  // Hall card
  // ═══════════════════════════════════════
  Widget _buildHallCard(
    HallsController ctrl,
    HallModel hall,
    ThemeData theme,
    AppColors colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.borderColor),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient strip with icon + name
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryPurple.withValues(alpha: 0.16),
                  AppColor.primaryPurple.withValues(alpha: 0.04),
                ],
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColor.purpleGradient,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.meeting_room_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hall.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    Icons.phone_outlined,
                    hall.phone1,
                    colors,
                    ltr: true,
                  ),
                  _buildInfoRow(
                    Icons.phone_android_outlined,
                    hall.phone2,
                    colors,
                    ltr: true,
                  ),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    hall.address,
                    colors,
                    fullText: true,
                  ),
                ],
              ),
            ),
          ),

          // Actions (the account hall is edited from the profile)
          if (!hall.isAccountHall)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit_outlined,
                      label: 'edit'.tr,
                      color: AppColor.primaryPurple,
                      onTap: () {
                        ctrl.setEditData(hall);
                        Get.dialog(
                          const HallFormDialog(isEdit: true),
                          barrierDismissible: true,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'delete'.tr,
                      color: Colors.red,
                      onTap: () => dialogDelete(
                        title: 'delete_confirm_btn'.tr,
                        content: 'delete_hall_confirm'.tr,
                        onConfirm: () => ctrl.deleteHall(hall.uuid!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Info line (phone / location); hidden when empty
  Widget _buildInfoRow(
    IconData icon,
    String? value,
    AppColors colors, {
    bool ltr = false,
    bool fullText = false,
  }) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: fullText
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.primaryPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: AppColor.primaryPurple),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textDirection: ltr ? TextDirection.ltr : null,
              // Phones are written LTR but sit next to the icon (right in Arabic)
              textAlign: Get.locale?.languageCode == 'ar'
                  ? TextAlign.right
                  : TextAlign.left,
              maxLines: fullText ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.subtitleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
