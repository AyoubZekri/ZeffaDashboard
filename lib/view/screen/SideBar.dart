import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/constant/AppTheme.dart';
import '../../controller/SiedBarController.dart';
import '../../core/constant/imageassets.dart';
import '../../core/localizations/ChengeLocal.dart';
import '../../view/widget/user_profile_dialog.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Siedbarcontroller>();
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colors.sidebarColor,
        border: Border(left: BorderSide(color: colors.borderColor, width: 1)),
      ),
      child: Column(
        children: [
          // Sidebar Header
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40.0,
              horizontal: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'app_name'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColor.primaryPurple,
                  ),
                ),
                Text(
                  'system_management'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.subtitleColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.screens.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final screen = controller.screens[index];
                final List subPages = screen['subPages'] ?? [];

                return Obx(() {
                  final isSelected = controller.currentPage.value == index;
                  final isExpanded = controller.expandedIndex.value == index;

                  if (subPages.isEmpty) {
                    return _buildMainItem(
                      controller,
                      index,
                      screen,
                      isSelected,
                      theme,
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMainItem(
                          controller,
                          index,
                          screen,
                          isSelected,
                          theme,
                          hasSubPages: true,
                          isExpanded: isExpanded,
                          onExpandToggle: () => controller.toggleExpand(index),
                        ),
                        if (isExpanded)
                          ...subPages.asMap().entries.map((subEntry) {
                            final subIndex = subEntry.key;
                            final subPage = subEntry.value;
                            final isSubSelected =
                                controller.currentSubIndex.value == subIndex &&
                                isSelected;

                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: _buildSubItem(
                                controller,
                                index,
                                subIndex,
                                subPage,
                                isSubSelected,
                                theme,
                              ),
                            );
                          }),
                      ],
                    );
                  }
                });
              },
            ),
          ),

          // Sidebar Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: AppColor.purpleGradient),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'add_sales'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainItem(
    Siedbarcontroller controller,
    int index,
    Map screen,
    bool isSelected,
    ThemeData theme, {
    bool hasSubPages = false,
    bool isExpanded = false,
    VoidCallback? onExpandToggle,
  }) {
    final colors = theme.extension<AppColors>()!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(colors: AppColor.purpleGradient)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: hasSubPages
            ? onExpandToggle
            : () => controller.changePage(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                screen['icon'],
                color: isSelected ? Colors.white : colors.subtitleColor,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  screen['name'].toString().tr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              if (hasSubPages)
                Icon(
                  isExpanded
                      ? Icons.expand_more_rounded
                      : Icons.chevron_left_rounded,
                  color: isSelected ? Colors.white : Colors.grey,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubItem(
    Siedbarcontroller controller,
    int parentIndex,
    int subIndex,
    Map subPage,
    bool isSelected,
    ThemeData theme,
  ) {
    final colors = theme.extension<AppColors>()!;
    return InkWell(
      onTap: () {
        controller.currentPage.value = parentIndex;
        controller.changeSubPage(subIndex, subPage['page']);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(right: 32),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryPurple.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColor.primaryPurple.withOpacity(0.2))
              : null,
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              subPage['icon'],
              color: isSelected ? AppColor.primaryPurple : colors.subtitleColor,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subPage['name'].toString().tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColor.primaryPurple
                      : colors.subtitleColor,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Siedbarcontroller());

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 1200;
        return Scaffold(
          drawer: isMobile ? const Drawer(child: SidebarWidget()) : null,
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                if (!isMobile) const SidebarWidget(),
                Expanded(
                  child: Column(
                    children: [
                      TopBar(isMobile: isMobile),
                      Expanded(
                        child: Obx(() {
                          if (controller.currentSubPage.value != null &&
                              controller.expandedIndex.value != null) {
                            return controller.currentSubPage.value!();
                          }
                          final screen =
                              controller.screens[controller.currentPage.value];
                          return screen['page'] != null
                              ? screen['page']()
                              : Center(child: Text('page_not_found'.tr));
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TopBar extends StatelessWidget {
  final bool isMobile;
  const TopBar({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Siedbarcontroller>();
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textColor = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(32, 24, 32, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colors.topBarColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColor.primaryPurple),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          // Search Field
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: colors.inputFillColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              textAlign: TextAlign.right,
              style: TextStyle(color: textColor, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'search_system'.tr,
                hintStyle: TextStyle(fontSize: 12, color: colors.subtitleColor),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.subtitleColor,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          const Spacer(),

          _buildTopButton(
            onPressed: () => controller.toggleDarkMode(),
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            theme: theme,
          ),
          const SizedBox(width: 12),
          _buildLanguageToggle(theme),
          const SizedBox(width: 12),
          _buildTopButton(
            onPressed: () {},
            icon: Icons.notifications_none_rounded,
            hasBadge: true,
            theme: theme,
          ),
          const SizedBox(width: 20),

          // Profile Section
          Obx(() {
            return Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      controller.hallname.value.isEmpty
                          ? "mock_user_name".tr
                          : controller.hallname.value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      controller.name.value.isEmpty
                          ? "mock_user_role".tr
                          : controller.name.value,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.subtitleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Get.dialog(const UserProfileDialog());
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: controller.imagePath.value != null
                        ? FileImage(File(controller.imagePath.value!))
                              as ImageProvider
                        : const AssetImage(Appimageassets.avater),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(ThemeData theme) {
    final LocalController localeController = Get.find<LocalController>();
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final colors = theme.extension<AppColors>()!;

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.inputFillColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangOption(
            label: "AR",
            isActive: isArabic,
            theme: theme,
            onTap: () => localeController.changeLang("ar"),
          ),
          const SizedBox(width: 2),
          _buildLangOption(
            label: "EN",
            isActive: !isArabic,
            theme: theme,
            onTap: () => localeController.changeLang("en"),
          ),
        ],
      ),
    );
  }

  Widget _buildLangOption({
    required String label,
    required bool isActive,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    final colors = theme.extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColor.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : colors.subtitleColor,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton({
    required VoidCallback onPressed,
    required IconData icon,
    bool hasBadge = false,
    required ThemeData theme,
  }) {
    final colors = theme.extension<AppColors>()!;
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: colors.subtitleColor, size: 22),
        ),
        if (hasBadge)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: colors.topBarColor, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
