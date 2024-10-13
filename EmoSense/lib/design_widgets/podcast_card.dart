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
  final String youtubeLink;

  PodcastCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.spotifyLink,
    required this.youtubeLink,
  });

  @override
  Widget build(BuildContext context) {
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
                height: 80,
                width: 80,
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
                  SizedBox(height: 25),
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
                                height: 120.0,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (await canLaunch(youtubeLink)) {
                                  await launch(youtubeLink);
                                }
                              },
                              child: Image.asset(
                                'assets/otherLogo/youtube.png',
                                height: 120.0,
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
