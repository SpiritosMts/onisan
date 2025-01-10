import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/components/Text/textFields.dart';
import 'package:onisan/components/snackbar/topAnimated.dart';

import 'package:sizer/sizer.dart';


class FeedbackWidget extends StatelessWidget {
  final Widget child;

  const FeedbackWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
      child: child,
      pixelRatio: 2.0, // Default pixel ratio
      theme: FeedbackThemeData(
        bottomSheetTextInputStyle: const TextStyle(color: Colors.black),
        bottomSheetDescriptionStyle: const TextStyle(color: Colors.black),
        feedbackSheetHeight: 0.25,
        sheetIsDraggable: true,
      ),
      feedbackBuilder: (context, onSubmit, controller) {
        return FeedbackForm(onSubmit: onSubmit);
      },
    );
  }
}

//********************************************************************************



class FeedbackForm extends StatefulWidget {
  final Future<void> Function(String feedback, {Map<String, dynamic>? extras}) onSubmit;

  FeedbackForm({required this.onSubmit});

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  // Create a TextEditingController to manage the TextField input
  final TextEditingController feedbackController = TextEditingController();
  bool isSubmitting = false; // Flag to track submission status

  @override
  void dispose() {
    feedbackController.dispose(); // Dispose the controller when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Text(
                    "What's Wrong".tr,
                    maxLines: 2,
                    style: TextStyle(),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: feedbackController, // Assign the controller here
                      decoration: InputDecoration(
                        hintText: 'Enter your feedback...',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      //maxLines: null, // Allows the text field to grow vertically
                      keyboardType: TextInputType.multiline, // Multi-line input
                      //enableInteractiveSelection: true, // Enable text selection
                      autofillHints: null, // Disable autofill
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: isSubmitting
              ? null // Disable button if submission is in progress
              : () async {
            setState(() {
              isSubmitting = true; // Set the flag to true to disable the button
            });

            hideKeyboard();
            try {
              await Future.delayed(Duration(milliseconds: 1500)); // Simulate a delay

              // Attempt to submit the feedback
              await widget.onSubmit(
                feedbackController.text,
                extras: {
                  'additionalInfo': 'Any extra information you want to pass',
                },
              );

              // If successful, reset the form (you can choose to reset or leave as is)
              setState(() {
                isSubmitting = false; // Optionally reset the form
                feedbackController.clear(); // Clear the feedback text field if needed
              });
            } catch (e) {
              // If there's an error, handle it and show an error message (you can customize this)
              setState(() {
                isSubmitting = false; // Re-enable the button on error
              });

              print("## feedback error : $e");
              animatedSnack(message: 'An error occurred. Please try again.');

            }

          },
          child: isSubmitting
              ? SizedBox(
            width: 20.0, // Adjust the size here
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0, // Adjust the thickness of the circle
            ),
          ) // Show a loading spinner while submitting
              : Text('Submit'.tr), // Show the button text when not submitting
        ),        const SizedBox(height: 18),
      ],
    );
  }
}

