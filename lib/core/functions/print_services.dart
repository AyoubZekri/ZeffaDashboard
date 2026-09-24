import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:get/get.dart';
import '../../data/model/ServiceModel.dart';
import '../services/Services.dart';

String ar(String text) {
  if (text.isEmpty) return "";

  String cleaned = text.replaceAll('\u00A0', ' ').replaceAll('\u202F', ' ');
  cleaned = cleaned.replaceAll(
    RegExp(r'[\u200B-\u200F\uFEFF\u202A-\u202E\u2060-\u206F]'),
    '',
  );
  cleaned = cleaned.replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '');
  cleaned = cleaned
      .replaceAll('’', "'")
      .replaceAll('`', "'")
      .replaceAll('‘', "'")
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('«', '"')
      .replaceAll('»', '"');
  cleaned = cleaned
      .replaceAll('\u06CC', '\u064A')
      .replaceAll('\u06A9', '\u0643');

  return cleaned
      .split('\n')
      .map((line) => ArabicReshaper.instance.reshape(line))
      .join('\n');
}

Future<void> generateAndPrintServicesPDF(List<ServiceModel> services) async {
  final Myservices myServices = Get.find();

  final String hallName =
      myServices.sharedPreferences?.getString("hallname") ??
      "قاعة حنكة للأفراح والمناسبات";
  final String adminPhone =
      myServices.sharedPreferences?.getString("numperPhone") ?? "0550147770";
  final String fieldPhone =
      myServices.sharedPreferences?.getString("fieldPhone") ?? "0773940087";

  final fontData = await rootBundle.load(
    "assets/fonts/static/Amiri-Regular.ttf",
  );
  final cairoFont = pw.Font.ttf(fontData);

  final boldFontData = await rootBundle.load(
    "assets/fonts/static/Amiri-Bold.ttf",
  );
  final cairoBold = pw.Font.ttf(boldFontData);

  final pdf = pw.Document();
  final textDir = pw.TextDirection.rtl;

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(35),
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            margin: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
          ),
        ),
      ),
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      build: (pw.Context context) {
        return [
          // Header Section
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left side (Customer Name & Date)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      ar(
                        "اسم الزبون : ...........................................",
                      ),
                      textDirection: textDir,
                      style: pw.TextStyle(font: cairoBold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      ar("التاريخ : ......./......./............."),
                      textDirection: textDir,
                      style: pw.TextStyle(font: cairoBold, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Right side (Hall Info)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      ar(hallName),
                      textDirection: textDir,
                      style: pw.TextStyle(font: cairoBold, fontSize: 14),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      ar("المسير الإداري: $adminPhone"),
                      textDirection: textDir,
                      style: pw.TextStyle(font: cairoFont, fontSize: 10),
                    ),
                    pw.Text(
                      ar("المسير الميداني: $fieldPhone"),
                      textDirection: textDir,
                      style: pw.TextStyle(font: cairoFont, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          // Title
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              border: pw.Border.all(color: PdfColors.black, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Center(
              child: pw.Text(
                ar("الخدمات الإضافية الإختيارية"),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoBold, fontSize: 14),
              ),
            ),
          ),
          pw.SizedBox(height: 15),
          // Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(1), // نعم / لا
              1: const pw.FlexColumnWidth(1.5), // السعر
              2: const pw.FlexColumnWidth(3), // الخدمة
            },
            children: [
              // Table Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Center(
                      child: pw.Text(
                        ar("نعم / لا"),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoBold, fontSize: 11),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Center(
                      child: pw.Text(
                        ar("السعر"),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoBold, fontSize: 11),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Center(
                      child: pw.Text(
                        ar("الخدمة"),
                        textDirection: textDir,
                        style: pw.TextStyle(font: cairoBold, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
              // Table Rows
              ...services.map((service) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(child: pw.Text("")),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          ar("${service.price?.toInt() ?? 0},00"),
                          textDirection: textDir,
                          style: pw.TextStyle(font: cairoBold, fontSize: 10),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          ar(service.name ?? ""),
                          textDirection: textDir,
                          style: pw.TextStyle(font: cairoBold, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.SizedBox(height: 20),
          // Signatures
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                ar("توقيع الزبون"),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoBold, fontSize: 11),
              ),
              pw.Text(
                ar("توقيع الإدارة"),
                textDirection: textDir,
                style: pw.TextStyle(font: cairoBold, fontSize: 11),
              ),
            ],
          ),
        ];
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
