import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/Colorapp.dart';

Future<Map<String, DateTime>?> showCustomRangePicker(BuildContext context,
    {DateTime? initialStart, DateTime? initialEnd}) async {
  DateTime now = DateTime.now();
  DateTime start = initialStart ?? now;
  DateTime end = initialEnd ?? now;

  int sDay = start.day, sMonth = start.month, sYear = start.year;
  int eDay = end.day, eMonth = end.month, eYear = end.year;

  return showDialog<Map<String, DateTime>>(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColor.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              "إختر المدة".tr,
              style: TextStyle(color: AppColor.backgroundcolor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("تاريخ البداية".tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.backgroundcolor)),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          magnification: 1.1,
                          squeeze: 1.2,
                          useMagnifier: true,
                          scrollController: FixedExtentScrollController(
                              initialItem: sDay - 1),
                          itemExtent: 30,
                          onSelectedItemChanged: (i) =>
                              setStateDialog(() => sDay = i + 1),
                          children: List.generate(
                              31, (i) => Center(child: Text("${i + 1}"))),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          magnification: 1.1,
                          squeeze: 1.2,
                          useMagnifier: true,
                          scrollController: FixedExtentScrollController(
                              initialItem: sMonth - 1),
                          itemExtent: 30,
                          onSelectedItemChanged: (i) =>
                              setStateDialog(() => sMonth = i + 1),
                          children: List.generate(
                              12, (i) => Center(child: Text("${i + 1}"))),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          magnification: 1.1,
                          squeeze: 1.2,
                          useMagnifier: true,
                          scrollController: FixedExtentScrollController(
                              initialItem: sYear - 2000),
                          itemExtent: 30,
                          onSelectedItemChanged: (i) =>
                              setStateDialog(() => sYear = 2000 + i),
                          children: List.generate(
                              50, (i) => Center(child: Text("${2000 + i}"))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text("تاريخ النهاية".tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.backgroundcolor)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          magnification: 1.1,
                          squeeze: 1.2,
                          useMagnifier: true,
                          scrollController: FixedExtentScrollController(
                              initialItem: eDay - 1),
                          itemExtent: 30,
                          onSelectedItemChanged: (i) =>
                              setStateDialog(() => eDay = i + 1),
                          children: List.generate(
                              31, (i) => Center(child: Text("${i + 1}"))),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          magnification: 1.1,
                          squeeze: 1.2,
                          useMagnifier: true,
                          scrollController: FixedExtentScrollController(
                              initialItem: eMonth - 1),
                          itemExtent: 30,
                          onSelectedItemChanged: (i) =>
                              setStateDialog(() => eMonth = i + 1),
                          children: List.generate(
                              12, (i) => Center(child: Text("${i + 1}"))),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          magnification: 1.1,
                          squeeze: 1.2,
                          useMagnifier: true,
                          scrollController: FixedExtentScrollController(
                              initialItem: eYear - 2000),
                          itemExtent: 30,
                          onSelectedItemChanged: (i) =>
                              setStateDialog(() => eYear = 2000 + i),
                          children: List.generate(
                              50, (i) => Center(child: Text("${2000 + i}"))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("إلغاء".tr)),
              ElevatedButton(
                onPressed: () {
                  DateTime startOfDay(DateTime d) =>
                      DateTime(d.year, d.month, d.day);
                  DateTime endOfDay(DateTime d) =>
                      DateTime(d.year, d.month, d.day, 23, 59, 59);

                  Navigator.pop(context, {
                    "start": startOfDay(DateTime(sYear, sMonth, sDay)),
                    "end": endOfDay(DateTime(eYear, eMonth, eDay)),
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.backgroundcolor,
                  foregroundColor: AppColor.white,
                ),
                child: Text(
                  "تأكيد".tr,
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
