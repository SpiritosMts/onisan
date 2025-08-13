// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:feedback/feedback.dart';
// import '../myTheme/themeManager.dart';

// class FeedbackWidget extends StatelessWidget {
//   final Widget child;

//   const FeedbackWidget({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return BetterFeedback(
//       theme: FeedbackThemeData(
//         background: Cm.greyCol.withOpacity(0.4),
//         feedbackSheetColor: Cm.bgCol,
//         drawColors: [
//           Cm.primaryColor,
//           const Color(0xFFE74C3C), // Red
//           const Color(0xFF2ECC71), // Green
//           const Color(0xFF3498DB), // Blue
//           const Color(0xFFF39C12), // Orange
//           const Color(0xFF9B59B6), // Purple
//           const Color(0xFF1ABC9C), // Teal
//           const Color(0xFFE67E22), // Dark Orange
//         ],
//         bottomSheetDescriptionStyle: TextStyle(
//           color: Cm.textCol,
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//         bottomSheetTextInputStyle: TextStyle(
//           color: Cm.textCol,
//           fontSize: 14,
//         ),
//         activeFeedbackModeColor: Cm.primaryColor,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Cm.primaryColor,
//           brightness: Brightness.dark,
//         ),
//       ),
//       feedbackBuilder: (context, onSubmit, controller) {
//         return FeedbackForm(onSubmit: onSubmit);
//       },
//       localizationsDelegates: [
//         CustomFeedbackLocalizations.delegate,
//       ],
//       localeOverride: Get.locale,
//       child: child,
//     );
//   }
// }

// // Custom localization for feedback package
// class CustomFeedbackLocalizations extends FeedbackLocalizations {
//   const CustomFeedbackLocalizations();

//   static const LocalizationsDelegate<FeedbackLocalizations> delegate = _CustomFeedbackLocalizationsDelegate();

//   @override
//   String get navigate => 'Navigate'.tr;

//   @override
//   String get draw => 'Draw'.tr;

//   @override
//   String get feedbackDescriptionText => 'What\'s wrong?'.tr;

//   @override
//   String get submitButtonText => 'Submit'.tr;
// }

// class _CustomFeedbackLocalizationsDelegate extends LocalizationsDelegate<FeedbackLocalizations> {
//   const _CustomFeedbackLocalizationsDelegate();

//   @override
//   bool isSupported(Locale locale) => true;

//   @override
//   Future<FeedbackLocalizations> load(Locale locale) async {
//     return const CustomFeedbackLocalizations();
//   }

//   @override
//   bool shouldReload(_CustomFeedbackLocalizationsDelegate old) => false;
// }

// class FeedbackForm extends StatefulWidget {
//   final Future<void> Function(String feedback, {Map<String, dynamic>? extras}) onSubmit;

//   FeedbackForm({required this.onSubmit});
//   @override
//   State<FeedbackForm> createState() => _FeedbackFormState();
// }

// class _FeedbackFormState extends State<FeedbackForm> {
//   // Create a TextEditingController to manage the TextField input
//   final TextEditingController feedbackController = TextEditingController();
//   bool isSubmitting = false; // Flag to track submission status

//   @override
//   void dispose() {
//     feedbackController.dispose(); // Dispose the controller when the widget is destroyed
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Color(0xFF1A1A1A),
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 ListView(
//                   padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
//                   physics: NeverScrollableScrollPhysics(),
//                   children: <Widget>[
//                     Text(
//                       "What's Wrong !".tr,
//                       maxLines: 2,
//                       style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: TextFormField(
//                         controller: feedbackController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter your feedback...'.tr,
//                           hintStyle: TextStyle(
//                             color: Colors.white54,
//                             fontSize: 16.0,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: Colors.white24),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: Cm.primaryColor),
//                           ),
//                           filled: true,
//                           fillColor: Color(0xFF232323),
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         ),
//                         style: TextStyle(color: Colors.white),
//                         keyboardType: TextInputType.multiline,
//                         autofillHints: null,
//                         cursorColor: Cm.primaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: isSubmitting
//                     ? null // Disable button if submission is in progress
//                     : () async {
//                   setState(() {
//                     isSubmitting = true;
//                   });
//                   FocusScope.of(context).requestFocus(FocusNode());
//                   try {
//                     await Future.delayed(Duration(milliseconds: 1500));
//                     await widget.onSubmit(
//                       feedbackController.text,
//                       extras: {
//                         'additionalInfo': 'Any extra information you want to pass',
//                       },
//                     );
//                     setState(() {
//                       isSubmitting = false;
//                       feedbackController.clear();
//                     });
//                   } catch (e) {
//                     setState(() {
//                       isSubmitting = false;
//                     });
//                     print("## feedback error : $e");
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('An error occurred. Please try again.'.tr)),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Cm.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: isSubmitting
//                     ? SizedBox(
//                         width: 20.0,
//                         height: 20.0,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2.0,
//                           color: Cm.secondaryColor,
//                         ),
//                       )
//                     : Text('Submit'.tr, style: TextStyle(fontSize: 16)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 18),
//         ],
//       ),
//     );
//   }
// }
