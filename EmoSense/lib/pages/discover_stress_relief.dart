// stress_relief_guide_content.dart
import 'package:emosense/api_services/youtube_services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';

class StressReliefGuideContent extends StatefulWidget {
  @override
  State<StressReliefGuideContent> createState() =>
      _StressReliefGuideContentState();
}

class _StressReliefGuideContentState extends State<StressReliefGuideContent> {
  List<Map<String, dynamic>> channelContents = [];
  final YouTubeService _youTubeService = YouTubeService();

  @override
  void initState() {
    super.initState();
    _fetchYouTubeChannelDetails();
  }

  Future<void> _fetchYouTubeChannelDetails() async {
    try {
      List<Map<String, dynamic>> channels = await _youTubeService.fetchYouTubeChannelDetails();
      setState(() {
        channelContents = channels;
      });
    } catch (error) {
      print('Error fetching YouTube channel details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.textFieldColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  child: Image.asset(
                    'assets/discover/relief.jpg',
                    height: 200.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Stress Relief and Management',
                      style: titleBlack.copyWith(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "Feeling stressed? You're not alone. \nStress is a natural part of life, "
                        "but learning how to manage and release it is essential for your well-being. "
                        "This guide will help you relax and unwind with guided sessions for stress relief.",
                    style: greySmallText.copyWith(
                        fontSize: 14.0, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Here are some helpful strategies to maintain balance and reduce stress:',
                    style: greySmallText.copyWith(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify,
                  ),
                  _buildStressReliefTechniques(),

                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Explore helpful YouTube channels for stress relief: \n',
              style: greySmallText.copyWith(
                  fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
            // Display YouTube channel information
            Column(
              children: channelContents.map((channel) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: GestureDetector(
                    onTap: () => _launchURL(channel['url']!),
                    child: Card(
                      color: AppColors.textFieldColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Image.network(
                              channel['thumbnail']!,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 10),
                            Text(
                              channel['title']!,
                              style: titleBlack.copyWith(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              channel['description']!,
                              maxLines: 17,
                              overflow: TextOverflow.ellipsis,
                              style: greySmallText.copyWith(fontSize: 14.0),
                              textAlign: TextAlign.justify,
                            ),
                            SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch URLs
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildStressReliefTechniques() {
    List<Map<String, String>> stressReliefTechniques = [
      {
        'title': '1. Deep Breathing Exercises',
        'description':
        'A few minutes of focused breathing can calm your mind and reduce tension.\n'
            'Try this:',
        'points':
        '- Find a quiet place to sit or lie down.\n'
            '- Close your eyes and take a slow, deep breath in through your nose for 4 seconds.\n'
            '- Hold your breath for 4 seconds.\n'
            '- Slowly exhale through your mouth for 4 seconds.\n'
            '- Repeat this for 5-10 minutes.',
      },
      {
        'title': '2. Progressive Muscle Relaxation',
        'description':
        'Tensing and then relaxing different muscle groups in your body can relieve physical tension.',
        'points':
        '- Start with your feet, tighten the muscles for a few seconds, then slowly release.\n'
            '- Move upward through your body—legs, stomach, arms, shoulders—until you’ve relaxed every muscle.',
      },
      {
        'title': '3. Mindfulness and Meditation',
        'description':
        'Taking a few minutes each day to focus on the present moment can help clear your mind and reduce anxiety.',
        'points':
            '- Sit in a comfortable position and focus on your breath.\n'
            '- Notice any thoughts that come to mind, but let them pass without judgment.\n'
            '- Try guided meditation apps or videos for more structured mindfulness sessions.',
      },
      {
        'title': '4. Physical Activity',
        'description':
        'Moving your body, even for a few minutes, releases endorphins, which are natural mood boosters.',
        'points':
            '- Go for a walk or do a quick workout.\n'
            '- Try stretching or yoga to release physical tension.',
      },
      {
        'title': '5. Time Management',
        'description':
        'Feeling overwhelmed by tasks can increase stress. Break your day into manageable chunks and prioritize your to-do list.',
        'points':
            '- Set realistic goals and take breaks when needed.\n'
            '- Try the Pomodoro technique: work for 25 minutes, then take a 5-minute break.',
      },
      {
        'title': '6. Music and Relaxation',
        'description':
        'Music can have a powerful effect on stress relief. Find calming or uplifting music to boost your mood.',
        'points':
            '- Listen to your favorite songs or try soothing instrumental tracks.\n'
            '- Use music apps or relaxation playlists designed to reduce stress.',
      },
      {
        'title': '7. Self-Compassion and Journaling',
        'description':
        'Be kind to yourself and recognize that it’s okay to feel stressed. Writing down your thoughts can help you process your emotions.',
        'points':
            '- Spend a few minutes journaling about your feelings or what’s causing your stress.\n'
            '- Write down three things you\'re grateful for to shift your focus.',
      },
      {
        'title': '8. Connect with Others',
        'description':
        'Talking to a friend or family member can provide emotional support and reduce stress.',
        'points':
            '- Share what you\'re going through with someone you trust.\n'
            '- Join an online support group if needed.',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: stressReliefTechniques.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stressReliefTechniques[index]['title']!,
                style: titleBlack.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPurpleColor,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                stressReliefTechniques[index]['description']!,
                style: greySmallText.copyWith(fontSize: 14.0),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8.0),
              _buildBulletPoints(stressReliefTechniques[index]['points']!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulletPoints(String points) {
    // Splitting the bullet points into separate lines
    List<String> pointList = points.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pointList.map((point) {
        if (point
            .trim()
            .isEmpty) {
          return SizedBox.shrink(); // Skips empty lines
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Text(
                  "•",
                  style: greySmallText.copyWith(fontSize: 14.0),
                ),
              ),
              Expanded(
                child: Text(
                  point.substring(1).trim(),
                  // Removes the "-" or bullet character
                  style: greySmallText.copyWith(fontSize: 14.0),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

}
