import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import '../../data/datasource/Remote/PartyTypes.dart';
import '../../data/model/PartyTypeModel.dart';

class EventTypesController extends GetxController {
  // Input fields for Add
  late TextEditingController typeName;
  late TextEditingController typeDesc;
  late TextEditingController typePrice;
  late TextEditingController typeSeasonalPrice;
  var selectedIcon = Icons.favorite_rounded.obs;

  // Input fields for Edit
  late TextEditingController editTypeName;
  late TextEditingController editTypeDesc;
  late TextEditingController editTypePrice;
  late TextEditingController editTypeSeasonalPrice;
  var editSelectedIcon = Icons.favorite_rounded.obs;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  // Available Icons for selection
  final List<IconData> availableIcons = [
    Icons.favorite_rounded,
    Icons.business_center_rounded,
    Icons.school_rounded,
    Icons.celebration_rounded,
    Icons.star_rounded,
    Icons.music_note_rounded,
    Icons.sports_esports_rounded,
    Icons.restaurant_rounded,
  ];

  // List of Event Types in RxList to update UI dynamically
  final RxList<Map<String, dynamic>> eventTypes = <Map<String, dynamic>>[].obs;

  final PartyTypes partyTypesRepo = PartyTypes(Get.find());
  Statusrequest statusrequest = Statusrequest.none;
  String? editUuid;

  @override
  void onInit() {
    typeName = TextEditingController();
    typeDesc = TextEditingController();
    typePrice = TextEditingController();
    typeSeasonalPrice = TextEditingController();

    editTypeName = TextEditingController();
    editTypeDesc = TextEditingController();
    editTypePrice = TextEditingController();
    editTypeSeasonalPrice = TextEditingController();

    loadEventTypes();
    super.onInit();
  }

  @override
  void onClose() {
    typeName.dispose();
    typeDesc.dispose();
    typePrice.dispose();
    typeSeasonalPrice.dispose();
    editTypeName.dispose();
    editTypeDesc.dispose();
    editTypePrice.dispose();
    editTypeSeasonalPrice.dispose();
    super.onClose();
  }

  Future<void> loadEventTypes() async {
    statusrequest = Statusrequest.loadeng;
    update();
    try {
      final result = await partyTypesRepo.viewdata();

      if (result.isEmpty) {
        statusrequest = Statusrequest.none;
        eventTypes.clear();
      } else {
        final models = PartyTypeModel.fromList(result);

        final mappedList = models.map((item) {
          IconData icon;
          if (item.icon != null && item.icon!.isNotEmpty) {
            final codePoint = int.tryParse(item.icon!);
            icon = codePoint != null
                ? IconData(codePoint, fontFamily: 'MaterialIcons')
                : Icons.favorite_rounded;
          } else {
            int iconIndex = (item.id ?? 0) % availableIcons.length;
            icon = availableIcons[iconIndex];
          }

          Color doubleColor = _getColorForIcon(icon);

          return {
            'uuid': item.uuid,
            'id': item.id,
            'titleKey': '',
            'descKey': '',
            'titleCustom': item.name ?? '',
            'descCustom': item.content ?? '',
            'price': _formatPrice(item.basicPrice?.toString() ?? '0'),
            'seasonalPrice': _formatPrice(
              item.seasonalPrice?.toString() ?? '0',
            ),
            'icon': icon,
            'iconBgColor': doubleColor.withOpacity(0.12),
            'iconColor': doubleColor,
          };
        }).toList();

        eventTypes.assignAll(mappedList);
        statusrequest = Statusrequest.success;
      }
    } catch (e) {
      print("Error loading Event Types: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  // Clear fields after add
  void clearFields() {
    typeName.clear();
    typeDesc.clear();
    typePrice.clear();
    typeSeasonalPrice.clear();
    selectedIcon.value = Icons.favorite_rounded;
    editUuid = null;
  }

  // Add new Event Type
  Future<void> addEventType() async {
    if (typeName.text.trim().isEmpty || typePrice.text.trim().isEmpty) return;

    // Parse prices
    final cleanPrice = typePrice.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final doublePrice = double.tryParse(cleanPrice) ?? 0.0;

    final cleanSeasonalPrice = typeSeasonalPrice.text.replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );
    final doubleSeasonalPrice = double.tryParse(cleanSeasonalPrice) ?? 0.0;

    final success = await partyTypesRepo.Adddata(
      typeName.text,
      typeDesc.text,
      doublePrice,
      doubleSeasonalPrice,
      selectedIcon.value.codePoint.toString(),
    );

    if (success) {
      clearFields();
      loadEventTypes();
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }

  // Set data for editing
  void setEditData(Map<String, dynamic> item) {
    editUuid = item['uuid'];
    editTypeName.text = item['titleKey'] != ''
        ? item['titleKey'].toString().tr
        : item['titleCustom'].toString();
    editTypeDesc.text = item['descKey'] != ''
        ? item['descKey'].toString().tr
        : item['descCustom'].toString();
    editTypePrice.text = item['price'].toString().replaceAll(',', '');
    editTypeSeasonalPrice.text = item['seasonalPrice'].toString().replaceAll(
      ',',
      '',
    );
    editSelectedIcon.value = item['icon'] as IconData;
  }

  // Update Event Type
  Future<void> updateEventType(String uuid) async {
    final cleanPrice = editTypePrice.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final doublePrice = double.tryParse(cleanPrice) ?? 0.0;

    final cleanSeasonalPrice = editTypeSeasonalPrice.text.replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );
    final doubleSeasonalPrice = double.tryParse(cleanSeasonalPrice) ?? 0.0;

    final success = await partyTypesRepo.Updatedata(
      uuid,
      editTypeName.text,
      editTypeDesc.text,
      doublePrice,
      doubleSeasonalPrice,
      editSelectedIcon.value.codePoint.toString(),
    );

    if (success) {
      loadEventTypes();
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }

  // Delete Event Type
  Future<void> deleteEventType(String uuid) async {
    final success = await partyTypesRepo.Deletedata(uuid);
    if (success) {
      loadEventTypes();
      Get.back();
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }

  // Helper to pick colors for dynamic icons
  Color _getColorForIcon(IconData icon) {
    if (icon == Icons.favorite_rounded) return const Color(0xFF673AB7);
    if (icon == Icons.business_center_rounded) return Colors.pink;
    if (icon == Icons.school_rounded) return Colors.blue;
    if (icon == Icons.celebration_rounded) return Colors.orange;
    if (icon == Icons.star_rounded) return Colors.amber;
    if (icon == Icons.music_note_rounded) return Colors.teal;
    if (icon == Icons.sports_esports_rounded) return Colors.deepOrange;
    return Colors.purple;
  }

  // Helper to format price with commas
  String _formatPrice(String priceStr) {
    final clean = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return '0';
    final value = int.parse(clean);
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
