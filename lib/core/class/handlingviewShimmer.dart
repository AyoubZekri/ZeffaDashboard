// import 'package:zeffa/core/constant/imageassets.DART';
// import 'package:flutter/widgets.dart';
// import 'package:lottie/lottie.dart';
// import 'package:zeffa/core/class/Statusrequest.dart';

// import '../../view/widget/Bills/CustemInvoiceItemShimmer.dart';

// class HandlingviewShimmer extends StatelessWidget {
//   final Statusrequest statusrequest;
//   final Widget widget;

//   const HandlingviewShimmer(
//       {super.key, required this.statusrequest, required this.widget});

//   @override
//   Widget build(BuildContext context) {
//     return statusrequest == Statusrequest.loadeng
//         ? ListView.builder(
//             itemCount: 10,
//             itemBuilder: (_, index) => const InvoiceItemShimmer(),
//           )
//         : statusrequest == Statusrequest.none
//             ? ListView.builder(
//                 itemCount: 10,
//                 itemBuilder: (_, index) => const InvoiceItemShimmer(),
//               )
//             : statusrequest == Statusrequest.failure
//                 ? Center(
//                     child: Lottie.asset(Appimageassets.nodata, width: 190),
//                   )
//                 : statusrequest == Statusrequest.serverfailure
//                     ? Center(
//                         child: Lottie.asset(Appimageassets.server, width: 190))
//                     : widget;
//   }
// }
