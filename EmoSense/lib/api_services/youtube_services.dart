// youtube_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  final String apiKey = 'AIzaSyA_Zhwl9ZC5QIPRYc9HDnsXjt3GpfowF9I'; // Your YouTube API Key

  final String meditationChannelId = 'UCN4vyryy6O4GlIXcXTIuZQQ';  // Great Meditation Channel ID
  final String yogaChannelId = 'UCFKE7WVJfvaHW5q283SxchA';       // Yoga with Adriene Channel ID

  // Fetch YouTube channel details for both meditation and yoga
  Future<List<Map<String, dynamic>>> fetchYouTubeChannelDetails() async {
    List<Map<String, dynamic>> channelContents = [];

    try {
      // List of channel IDs
      List<String> channelIds = [meditationChannelId, yogaChannelId];

      for (String channelId in channelIds) {
        String apiUrl =
            'https://www.googleapis.com/youtube/v3/channels?key=$apiKey&id=$channelId&part=snippet,statistics';

        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);

          if (data['items'] != null && data['items'].isNotEmpty) {
            var channel = data['items'][0];
            channelContents.add({
              'title': channel['snippet']['title'],
              'description': channel['snippet']['description'],
              'thumbnail': channel['snippet']['thumbnails']['high']['url'],
              'subscriberCount': channel['statistics']['subscriberCount'],
              'videoCount': channel['statistics']['videoCount'],
              'url': 'https://www.youtube.com/channel/$channelId',
            });
          }
        } else {
          throw 'Failed to fetch channel details';
        }
      }
    } catch (error) {
      print('Error fetching YouTube channel details: $error');
    }

    return channelContents;
  }
}
