import 'package:emosense/design_widgets/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart';  // Import your SignUpPage

class GetStartedPage extends StatelessWidget {
  static const routeName = '/GetStartedPage';
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve screen height and width using MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate dynamic padding and font sizes based on screen dimensions
    double horizontalPadding = screenWidth * 0.05; // 5% of the screen width
    double buttonHeight = screenHeight * 0.08;     // 8% of the screen height
    double fontSizeTitle = screenHeight * 0.05;    // 5% of the screen height for the title
    double fontSizeSubtitle = screenHeight * 0.02; // 2% of the screen height for the subtitle

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.02),
          // Welcome Text
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Welcome",
                style: TextStyle(
                  fontSize: fontSizeTitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPurpleColor,
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),  // Dynamic spacing

          // Emoji or Image Placeholder
          Icon(
            Icons.emoji_emotions_outlined,
            size: screenHeight * 0.15,  // Emoji size as a percentage of screen height
            color: AppColors.darkLogoColor,  // You can use your custom color here
          ),

          SizedBox(height: screenHeight * 0.04),  // Dynamic spacing
          // Placeholder Text
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              "Still thinking what to write",
              style: TextStyle(
                fontSize: fontSizeSubtitle,
                color: AppColors.textColorBlack,
              ),
            ),
          ),

          Spacer(),
          // Let's Get Started Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              width: double.infinity,  // Takes the full width of the screen
              height: buttonHeight,     // Dynamic button height
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPurpleColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),  // Add rounded corners if needed
                  ),
                ),
                child: Text(
                  "Let’s get started",
                  style: TextStyle(
                    fontFamily: 'Aptos',
                    fontSize: screenHeight * 0.023,  // Dynamic font size for button text
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),  // Add some space at the bottom
        ],
      ),
    );
  }
}
