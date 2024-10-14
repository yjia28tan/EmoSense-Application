import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PodcastCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String spotifyLink;
  final String? youtubeLink; // Make youtubeLink nullable

  PodcastCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.spotifyLink,
    this.youtubeLink, // Change here to make it optional
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: AppColors.textFieldColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Podcast Image
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: greySmallText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: greySmallText.copyWith(fontSize: 12),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Play on:",
                          style: greySmallText.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (await canLaunch(spotifyLink)) {
                                  await launch(spotifyLink);
                                }
                              },
                              child: Image.asset(
                                'assets/otherLogo/spotify.png',
                                height: 60.0,
                              ),
                            ),
                            // Conditionally display YouTube logo
                            if (youtubeLink != null) // Only display if youtubeLink is not null
                              GestureDetector(
                                onTap: () async {
                                  if (await canLaunch(youtubeLink!)) {
                                    await launch(youtubeLink!);
                                  }
                                },
                                child: Image.asset(
                                  'assets/otherLogo/youtube.png',
                                  height: 60.0,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
