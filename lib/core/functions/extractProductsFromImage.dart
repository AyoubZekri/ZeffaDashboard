// import 'dart:io';
// import 'package:google_generative_ai/google_generative_ai.dart';

// Future<String> extractProductsFromImage(File imageFile) async {
//   final apiKey = 'AIzaSyBLL8gOhxj9zxDvBkPMfiW-WInSN7bJeus';

//   final model = GenerativeModel(
//     model: 'gemini-1.5-flash',
//     apiKey: apiKey,
//   );

//   final imageBytes = await imageFile.readAsBytes();
//   final imagePart = DataPart('image/jpeg', imageBytes);

//   final prompt = '''
// اقرأ الصورة التالية واستخرج المنتجات فقط بصيغة JSON خام، بدون أي شرح أو كلام إضافي. يجب أن يكون الإخراج يبدأ مباشرة بـ "[" وينتهي بـ "]".

// الصيغة المطلوبة:

// [
//   {
//     "name": "اسم المنتج",
//     "price": "السعر",
//     "quantity": "الكمية"
//   }
// ]
// ''';

//   final response = await model.generateContent([
//     Content.multi([
//       TextPart(prompt),
//       imagePart,
//     ])
//   ]);

//   return response.text ?? "فشل في القراءة";
// }
