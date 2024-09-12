import 'package:emosense/api_services/quote_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late Future<QuoteResponse?> quoteFuture;
  final GetQoutesClass qouoteData = GetQoutesClass();


  @override
  void initState() {
    super.initState();
    // Initialize or refresh data here
    quoteFuture = qouoteData.getQuote();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.downBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.06
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Quotes of the day",
                    style: titleBlack,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              FutureBuilder<QuoteResponse?>(
                future: quoteFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Failed to load quote');
                  } else if (snapshot.hasData) {
                    final quote = snapshot.data;
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.upBackgroundColor, // Background color
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_pin_sharp,
                                  color: AppColors.darkPurpleColor
                                ),
                                SizedBox(width: 8.0), // Add some space between the icon and the text
                                Flexible(
                                  child: Text(
                                    ' ${quote?.author ?? 'Leo Tolstoy'}',
                                    style: GoogleFonts.leagueSpartan(
                                      color: AppColors.darkPurpleColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2, // Allow the text to wrap into two lines if needed
                                    overflow: TextOverflow.ellipsis, // Optional: adds an ellipsis if the text is too long
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            quote?.content ?? 'Trust yourself. You’ve survived a lot, and you’ll survive whatever is coming.',
                            style: GoogleFonts.leagueSpartan(
                                color: Color(0xFFF2F2F2),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.upBackgroundColor, // Background color
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              children: [
                                const Icon(
                                    Icons.person_pin_sharp,
                                    color: AppColors.darkPurpleColor
                                ),
                                SizedBox(width: 8.0), // Add some space between the icon and the text
                                Flexible(
                                  child: Text(
                                    'Christian D Larson',
                                    style: GoogleFonts.leagueSpartan(
                                      color: AppColors.darkPurpleColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2, // Allow the text to wrap into two lines if needed
                                    overflow: TextOverflow.ellipsis, // Optional: adds an ellipsis if the text is too long
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Believe in yourself and all that you are. Know that there is something inside of you that is greater than any obstacle.',
                            style: GoogleFonts.leagueSpartan(
                                color: Color(0xFFF2F2F2),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: screenHeight * 0.04),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Meditation Guides",
                  style: titleBlack,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

            ],
          ),
        ),

      ),
    );
  }
}