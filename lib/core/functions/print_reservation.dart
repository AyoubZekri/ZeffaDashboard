import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:zeffa/core/functions/format_money.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import '../../data/model/ReservationModel.dart';
import '../class/Sqldb.dart';
import '../services/Services.dart';
import '../../data/datasource/Remote/Halls.dart';

String ar(String text) {
  if (text.isEmpty) return "";

  // 1. Replace non-breaking spaces with standard spaces
  String cleaned = text.replaceAll('\u00A0', ' ').replaceAll('\u202F', ' ');

  // 2. Remove zero-width spaces, directional markers, and control characters
  cleaned = cleaned.replaceAll(
    RegExp(r'[\u200B-\u200F\uFEFF\u202A-\u202E\u2060-\u206F]'),
    '',
  );

  // 3. Remove Arabic diacritics (Harakat / Tashkeel) which cause missing glyph squares in pdf
  cleaned = cleaned.replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '');

  // 4. Normalize common typographic symbols that might be missing from Cairo font
  cleaned = cleaned
      .replaceAll('’', "'")
      .replaceAll('`', "'")
      .replaceAll('‘', "'")
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('«', '"')
      .replaceAll('»', '"');

  // 5. Normalize Farsi Yeh (\u06CC) and Farsi Kaf (\u06A9) to standard Arabic Yeh (\u064A) and Kaf (\u0643)
  cleaned = cleaned
      .replaceAll('\u06CC', '\u064A')
      .replaceAll('\u06A9', '\u0643');

  return cleaned
      .split('\n')
      .map((line) => ArabicReshaper.instance.reshape(line))
      .join('\n');
}

String getPeriodLabel(int? period) {
  final isArabic = Get.locale?.languageCode == 'ar';
  if (isArabic) {
    switch (period) {
      case 1:
        return "يوم كامل";
      case 2:
        return "نصف يوم";
      case 3:
        return "فترة مسائية";
      case 4:
        return "فترة صباحية";
      default:
        return "غير محدد";
    }
  } else {
    switch (period) {
      case 1:
        return "Full Day";
      case 2:
        return "Half Day";
      case 3:
        return "Evening Period";
      case 4:
        return "Morning Period";
      default:
        return "Unspecified";
    }
  }
}

void showPrintSelectionDialog(
  BuildContext context,
  ReservationModel reservation,
) {
  final isArabic = Get.locale?.languageCode == 'ar';

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? "طباعة وثائق الحجز" : "Print Booking Documents",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? "اختر المستندات التي ترغب في طباعتها بصيغة PDF:"
                  : "Select the documents you wish to print as PDF:",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            _buildPrintOption(
              icon: Icons.print_rounded,
              title: isArabic
                  ? "طباعة كافة الوثائق (3 صفحات)"
                  : "Print All Documents (3 Pages)",
              subtitle: isArabic
                  ? "العقد، القانون الداخلي، والمواد المطلوبة"
                  : "Contract, Internal Rules & Required Materials",
              onTap: () {
                Get.back();
                generateAndPrintPDF(reservation, 0);
              },
            ),
            const Divider(),
            _buildPrintOption(
              icon: Icons.description_rounded,
              title: isArabic ? "طباعة عقد الحجز" : "Print Booking Contract",
              subtitle: isArabic
                  ? "العقد الرسمي والتفاصيل المالية للحجز"
                  : "Official contract and financial details",
              onTap: () {
                Get.back();
                generateAndPrintPDF(reservation, 1);
              },
            ),
            const Divider(),
            _buildPrintOption(
              icon: Icons.gavel_rounded,
              title: isArabic
                  ? "طباعة القانون الداخلي للقاعة"
                  : "Print Internal Rules",
              subtitle: isArabic
                  ? "القواعد والشروط التنظيمية الداخلية"
                  : "Internal rules and regulations of the hall",
              onTap: () {
                Get.back();
                generateAndPrintPDF(reservation, 2);
              },
            ),
            const Divider(),
            _buildPrintOption(
              icon: Icons.assignment_rounded,
              title: isArabic
                  ? "طباعة المواد المطلوبة والإجراءات"
                  : "Print Required Materials & Procedures",
              subtitle: isArabic
                  ? "قائمة المشتريات والتنظيمات الميدانية"
                  : "Shopping list and field instructions",
              onTap: () {
                Get.back();
                generateAndPrintPDF(reservation, 3);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    isArabic ? "إلغاء" : "Cancel",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

Widget _buildPrintOption({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.deepPurple),
    ),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
    onTap: onTap,
  );
}

Future<void> generateAndPrintPDF(
  ReservationModel reservation,
  int option,
) async {
  final SQLDB db = SQLDB();
  final Myservices myServices = Get.find();

  final int userId = myServices.sharedPreferences?.getInt("id") ?? 1;
  // Hall of the reservation: its name, and its phones when they were added
  // (otherwise the account phones). No hall → the account hall.
  final hall = await Halls(myServices).hallForPrint(reservation.hallUuid);
  final String hallName = hall.name ?? "";
  final String adminPhone = hall.phone1 ?? "";
  final String fieldPhone = hall.phone2 ?? "";
  // Hall numbers one after the other, separated by " - "
  final String hallPhones = [
    adminPhone,
    fieldPhone,
  ].where((p) => p.trim().isNotEmpty).join(" - ");
  final String address = hall.address ?? "";

  final bool isArabic = Get.locale?.languageCode == 'ar';

  String tr(String arText, String enText) {
    return ar(isArabic ? arText : enText);
  }

  final textDir = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
  final alignRight = isArabic
      ? pw.Alignment.centerRight
      : pw.Alignment.centerLeft;
  final alignLeft = isArabic
      ? pw.Alignment.centerLeft
      : pw.Alignment.centerRight;

  // Load terms from database
  List<Map<String, dynamic>> rawTerms = [];
  try {
    rawTerms = await db.readData(
      '''
      SELECT t.uuid, t.title, t.type, tc.content 
      FROM Terms t 
      LEFT JOIN Terms_content tc ON t.uuid = tc.term_uuid 
      WHERE t.user_id = ?
      ORDER BY t.created_at ASC
      ''',
      [userId],
    );
  } catch (e) {
    print("Error loading terms for printing: $e");
  }

  // Group rows by Term uuid to collect all content items
  final Map<String, Map<String, dynamic>> termsMap = {};
  for (final row in rawTerms) {
    final termUuid = row["uuid"] as String?;
    if (termUuid == null) continue;
    if (!termsMap.containsKey(termUuid)) {
      termsMap[termUuid] = {
        "title": row["title"] ?? "",
        "type": row["type"] ?? "",
        "contents": <String>[],
      };
    }
    final content = row["content"];
    if (content != null && (content as String).isNotEmpty) {
      (termsMap[termUuid]!["contents"] as List<String>).add(content);
    }
  }

  // Now, separate by type
  final List<Map<String, dynamic>> dbInternalRules = [];
  final List<Map<String, dynamic>> dbContractTerms = [];
  final List<Map<String, dynamic>> dbRequiredProcedures = [];
  final List<Map<String, dynamic>> dbRequiredDocuments = [];

  for (final term in termsMap.values) {
    final String type = term["type"];
    if (type == 'internal_rules') {
      dbInternalRules.add(term);
    } else if (type == 'contract_terms') {
      dbContractTerms.add(term);
    } else if (type == 'required_procedures') {
      dbRequiredProcedures.add(term);
    } else if (type == 'required_documents') {
      dbRequiredDocuments.add(term);
    }
  }

  List<Map<String, dynamic>> internalRules = [];
  if (dbInternalRules.isNotEmpty) {
    internalRules = dbInternalRules;
  }

  List<Map<String, dynamic>> contractTerms = [];
  if (dbContractTerms.isNotEmpty) {
    contractTerms = dbContractTerms;
  }

  List<Map<String, dynamic>> requiredProcedures = [];
  if (dbRequiredProcedures.isNotEmpty) {
    requiredProcedures = dbRequiredProcedures;
  }

  int totalGuests =
      (reservation.numberOfMen ?? 0) + (reservation.numberOfWomen ?? 0);
  if (totalGuests <= 0) totalGuests = 1;

  List<String> requiredDocuments = [];
  if (dbRequiredDocuments.isNotEmpty) {
    for (final doc in dbRequiredDocuments) {
      final String title = doc["title"] ?? "";
      final List<String> contents = List<String>.from(doc["contents"] ?? []);
      if (contents.isNotEmpty) {
        List<String> parsedItems = [];
        for (String c in contents) {
          // Plain text (old format) → printed as is, no JSON decode
          if (!c.trimLeft().startsWith('{')) {
            parsedItems.add("$title ........ $c");
            continue;
          }
          try {
            final decoded = jsonDecode(c);
            final name = decoded['name'] ?? title; // Fallback to title
            final double baseQty =
                (decoded['quantity'] as num?)?.toDouble() ?? 1.0;
            final String unit = decoded['unit'] ?? '';
            final int coversGuests =
                (decoded['covers_guests'] as num?)?.toInt() ?? 100;

            int cGuests = coversGuests > 0 ? coversGuests : 100;
            double scale = totalGuests / cGuests;
            int finalQty = (baseQty * scale).ceil();

            parsedItems.add("$name ........ $finalQty $unit");
          } catch (e) {
            parsedItems.add("$title ........ $c");
          }
        }
        requiredDocuments.add(parsedItems.join('\n'));
      } else {
        requiredDocuments.add(title);
      }
    }
  }

  // Load fonts (using Amiri instead of Cairo because Cairo lacks some isolated presentation form glyphs)
  final fontData = await rootBundle.load(
    "assets/fonts/static/Amiri-Regular.ttf",
  );
  final cairoFont = pw.Font.ttf(fontData);

  final boldFontData = await rootBundle.load(
    "assets/fonts/static/Amiri-Bold.ttf",
  );
  final cairoBold = pw.Font.ttf(boldFontData);

  final pdf = pw.Document();

  // Page 1 builder: required materials & procedures
  pw.Page buildMaterialsPage() {
    int mid = (requiredDocuments.length / 2).ceil();
    List<String> col1 = requiredDocuments.sublist(0, mid);
    List<String> col2 = requiredDocuments.sublist(mid);

    return pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(42),
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            margin: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.5),
            ),
            padding: const pw.EdgeInsets.all(3),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
              ),
            ),
          ),
        ),
      ),
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text(
              ar(hallName),
              textDirection: textDir,
              style: pw.TextStyle(font: cairoBold, fontSize: 20),
            ),
          ),
          pw.SizedBox(height: 4),
          if (hallPhones.isNotEmpty) ...[
            pw.Center(
              child: pw.Text(
                ar(hallPhones),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoFont, fontSize: 11),
              ),
            ),
          ],
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                tr(
                  "تاريخ الحجز: ${reservation.bookingDate}",
                  "Booking Date: ${reservation.bookingDate}",
                ),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoFont, fontSize: 10),
              ),
              pw.Text(
                tr(
                  "حجز رقم: ${reservation.id ?? reservation.uuid.substring(0, 8)}",
                  "Booking No: ${reservation.id ?? reservation.uuid.substring(0, 8)}",
                ),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoFont, fontSize: 10),
              ),
            ],
          ),
          pw.Divider(thickness: 1, color: PdfColors.black),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              tr("المواد المطلوبة", "Required Materials"),
              textDirection: textDir,
              style: pw.TextStyle(font: cairoBold, fontSize: 14),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: col1
                      .map(
                        (item) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Align(
                            alignment: alignRight,
                            child: pw.Text(
                              "• ${ar(item)}",
                              textDirection: textDir,
                              style: pw.TextStyle(
                                font: cairoFont,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              pw.SizedBox(width: 24),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: col2
                      .map(
                        (item) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Align(
                            alignment: alignRight,
                            child: pw.Text(
                              "• ${ar(item)}",
                              textDirection: textDir,
                              style: pw.TextStyle(
                                font: cairoFont,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(thickness: 0.5, color: PdfColors.black),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              tr("إجراءات تنظيمية", "Regulatory Procedures"),
              textDirection: textDir,
              style: pw.TextStyle(font: cairoBold, fontSize: 14),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: requiredProcedures.map((proc) {
              final title = proc["title"] ?? "";
              final contents = List<String>.from(proc["contents"] ?? []);

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                    child: pw.Align(
                      alignment: alignRight,
                      child: pw.Text(
                        ar(title),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoFont, fontSize: 14),
                      ),
                    ),
                  ),
                  if (contents.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 15, bottom: 3),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: contents.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final text = entry.value;
                          return pw.Align(
                            alignment: alignRight,
                            child: pw.Text(
                              ar(isArabic ? "$idx- $text" : "$idx. $text"),
                              textDirection: textDir,
                              style: pw.TextStyle(
                                font: cairoFont,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
          pw.SizedBox(height: 30),

          pw.Align(
            alignment: alignLeft,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  tr("امضاء مسير القاعة", "Hall Manager Signature"),
                  textDirection: textDir,
                  style: pw.TextStyle(font: cairoBold, fontSize: 10),
                ),
                pw.SizedBox(height: 35),
              ],
            ),
          ),
          pw.Center(
            child: pw.Text(
              tr(
                "نشكركم على ثقتكم ودامت افراحكم",
                "Thank you for your trust, may your joys last",
              ),
              textDirection: textDir,
              style: pw.TextStyle(
                font: cairoFont,
                fontSize: 14,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
        ];
      },
    );
  }

  // Page 2 builder: internal regulations
  pw.Page buildInternalRulesPage() {
    return pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(42),
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            margin: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.5),
            ),
            padding: const pw.EdgeInsets.all(3),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
              ),
            ),
          ),
        ),
      ),
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text(
              ar(hallName),
              textDirection: textDir,
              style: pw.TextStyle(font: cairoBold, fontSize: 20),
            ),
          ),
          pw.SizedBox(height: 4),
          if (hallPhones.isNotEmpty) ...[
            pw.Center(
              child: pw.Text(
                ar(hallPhones),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoFont, fontSize: 11),
              ),
            ),
            pw.SizedBox(height: 4),
          ],
          pw.Center(
            child: pw.Text(
              ar(address),
              textDirection: textDir,
              style: pw.TextStyle(
                font: cairoFont,
                fontSize: 11,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Divider(thickness: 1, color: PdfColors.black),
          pw.SizedBox(height: 12),
          pw.Center(
            child: pw.Text(
              tr("القانون الداخلي للقاعة", "Internal Regulations of the Hall"),
              textDirection: textDir,
              style: pw.TextStyle(font: cairoBold, fontSize: 15),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: internalRules.map((rule) {
              final title = rule["title"] ?? "";
              final contents = List<String>.from(rule["contents"] ?? []);

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                    child: pw.Align(
                      alignment: alignRight,
                      child: pw.Text(
                        ar(title),
                        textDirection: textDir,
                        style: pw.TextStyle(
                          font: cairoFont,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  if (contents.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 15, bottom: 4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: contents.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final text = entry.value;
                          return pw.Align(
                            alignment: alignRight,
                            child: pw.Text(
                              ar(isArabic ? "$idx- $text" : "$idx. $text"),
                              textDirection: textDir,
                              style: pw.TextStyle(
                                font: cairoFont,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
          pw.Align(
            alignment: alignLeft,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  tr("امضاء مسير القاعة", "Hall Manager Signature"),
                  textDirection: textDir,
                  style: pw.TextStyle(font: cairoBold, fontSize: 10),
                ),
                pw.SizedBox(height: 35),
              ],
            ),
          ),
        ];
      },
    );
  }

  // Page 3 builder: contract page
  pw.Page buildContractPage() {
    return pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(42),
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            margin: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.5),
            ),
            padding: const pw.EdgeInsets.all(3),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
              ),
            ),
          ),
        ),
      ),
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text(
              ar(hallName),
              textDirection: textDir,
              style: pw.TextStyle(font: cairoBold, fontSize: 20),
            ),
          ),
          pw.SizedBox(height: 4),
          if (hallPhones.isNotEmpty) ...[
            pw.Center(
              child: pw.Text(
                ar(hallPhones),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoFont, fontSize: 11),
              ),
            ),
            pw.SizedBox(height: 4),
          ],
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                tr(
                  "الوادي في: ${reservation.bookingDate}",
                  "Date: ${reservation.bookingDate}",
                ),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoFont, fontSize: 10),
              ),
              pw.Text(
                tr(
                  "عقد حجز رقم: ${reservation.id ?? reservation.uuid.substring(0, 8)}",
                  "Booking Contract No: ${reservation.id ?? reservation.uuid.substring(0, 8)}",
                ),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoFont, fontSize: 10),
              ),
            ],
          ),
          pw.Divider(thickness: 1, color: PdfColors.black),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: alignRight,
            child: pw.Text(
              tr("الطرف الأول: $hallName.", "First Party: $hallName."),
              textDirection: textDir,
              style: pw.TextStyle(font: cairoBold, fontSize: 10.5),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Align(
            alignment: alignRight,
            child: pw.Text(
              tr(
                "الطرف الثاني : ${reservation.customerName}                 رقم الهاتف: ${reservation.phoneNumber}",
                "Second Party: ${reservation.customerName}                 Phone Number: ${reservation.phoneNumber}",
              ),
              textDirection: textDir,
              style: pw.TextStyle(font: cairoFont, fontSize: 10.5),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Center(
            child: pw.Text(
              tr("بنود العقد", "Contract Clauses"),
              textDirection: textDir,
              style: pw.TextStyle(font: cairoBold, fontSize: 14),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        tr("القسط المتبقي", "Remaining"),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoBold, fontSize: 9.5),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        tr("القسط المدفوع", "Paid"),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoBold, fontSize: 9.5),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        tr("قيمة الحجز", "Price"),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoBold, fontSize: 9.5),
                      ),
                    ),
                  ),
                  // Guests: shown only when the count isn't 0
                  if (reservation.numberOfWomen > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(
                          tr("عدد النساء", "Women"),
                          textDirection: textDir,
                          style: pw.TextStyle(font: cairoBold, fontSize: 9.5),
                        ),
                      ),
                    ),
                  if (reservation.numberOfMen > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(
                          tr("عدد الرجال", "Men"),
                          textDirection: textDir,
                          style: pw.TextStyle(font: cairoBold, fontSize: 9.5),
                        ),
                      ),
                    ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        tr("فترة الحجز", "Period"),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoBold, fontSize: 9.5),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        tr("تاريخ الحجز", "Date"),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoBold, fontSize: 9.5),
                      ),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        tr(
                          "${formatMoney(reservation.remainingAmount)} د.ج",
                          "${formatMoney(reservation.remainingAmount)} DZD",
                        ),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoFont, fontSize: 9),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        tr(
                          "${formatMoney(reservation.deposit)} د.ج",
                          "${formatMoney(reservation.deposit)} DZD",
                        ),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoFont, fontSize: 9),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        tr(
                          "${formatMoney(reservation.price)} د.ج",
                          "${formatMoney(reservation.price)} DZD",
                        ),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoFont, fontSize: 9),
                      ),
                    ),
                  ),
                  if (reservation.numberOfWomen > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(
                          ar("${reservation.numberOfWomen}"),
                          textDirection: textDir,
                          style: pw.TextStyle(font: cairoFont, fontSize: 9),
                        ),
                      ),
                    ),
                  if (reservation.numberOfMen > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(
                          ar("${reservation.numberOfMen}"),
                          textDirection: textDir,
                          style: pw.TextStyle(font: cairoFont, fontSize: 9),
                        ),
                      ),
                    ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        ar(getPeriodLabel(reservation.bookingPeriod)),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoFont, fontSize: 9),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        ar(reservation.bookingDate),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoFont, fontSize: 9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: contractTerms.map((term) {
              final title = term["title"] ?? "";
              final contents = List<String>.from(term["contents"] ?? []);

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                    child: pw.Align(
                      alignment: alignRight,
                      child: pw.Text(
                        ar(title),
                        textDirection: textDir,
                        style: pw.TextStyle(
                          font: cairoFont,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  if (contents.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 15, bottom: 3),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: contents.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final text = entry.value;
                          return pw.Align(
                            alignment: alignRight,
                            child: pw.Text(
                              ar(isArabic ? "$idx- $text" : "$idx. $text"),
                              textDirection: textDir,
                              style: pw.TextStyle(
                                font: cairoFont,
                                fontSize: 14,
                                height: 1.25,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    tr("إمضاء مسير القاعة", "Hall Manager Signature"),
                    textDirection: textDir,
                    style: pw.TextStyle(font: cairoBold, fontSize: 10),
                  ),
                  pw.SizedBox(height: 35),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    tr("إمضاء صاحب الحجز", "Client Signature"),
                    textDirection: textDir,
                    style: pw.TextStyle(font: cairoBold, fontSize: 10),
                  ),
                  pw.SizedBox(height: 35),
                ],
              ),
            ],
          ),
        ];
      },
    );
  }

  // Choose pages depending on selected print option
  if (option == 0) {
    pdf.addPage(buildContractPage());
    pdf.addPage(buildInternalRulesPage());
    pdf.addPage(buildMaterialsPage());
  } else if (option == 1) {
    pdf.addPage(buildContractPage());
  } else if (option == 2) {
    pdf.addPage(buildInternalRulesPage());
  } else if (option == 3) {
    pdf.addPage(buildMaterialsPage());
  }

  // Build the PDF once: the print dialog may call onLayout several times
  // (preview, open PDF...) and re-laying out all papers each time failed
  // when the three were printed together.
  try {
    final bytes = await pdf.save();
    // ASCII file name (an Arabic name came out garbled in the saved file)
    final fileName =
        "reservation_${reservation.numperReservation ?? reservation.id ?? reservation.uuid.substring(0, 8)}";

    // Desktop: saving through a PDF printer goes through the print spooler,
    // and the PDF reader opened the file before it was fully written
    // ("sharing violation"). Offer to save the file directly instead.
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final choice = await Get.dialog<String>(_printOrSaveDialog());
      if (choice == null) return;
      if (choice == 'save') {
        final path = await FilePicker.platform.saveFile(
          fileName: "$fileName.pdf",
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          bytes: bytes,
        );
        if (path != null) await launchUrl(Uri.file(path));
        return;
      }
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: fileName,
    );
  } catch (e, st) {
    print("❌ PDF error: $e");
    print(st);
    Get.snackbar("error".tr, e.toString());
  }
}

/// Desktop choice after building the papers: save as a PDF file or print
Widget _printOrSaveDialog() {
  Widget option(String value, IconData icon, String label, bool primary) {
    return Expanded(
      child: primary
          ? ElevatedButton.icon(
              onPressed: () => Get.back(result: value),
              icon: Icon(icon, size: 20),
              label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C2983),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          : OutlinedButton.icon(
              onPressed: () => Get.back(result: value),
              icon: Icon(icon, size: 20),
              label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4C2983),
                side: const BorderSide(color: Color(0xFF4C2983)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
    );
  }

  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, size: 40, color: Color(0xFF4C2983)),
            const SizedBox(height: 12),
            Text(
              'documents_ready'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                option('save', Icons.save_alt_rounded, 'save_as_pdf'.tr, true),
                const SizedBox(width: 12),
                option('print', Icons.print_rounded, 'print_documents'.tr, false),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
