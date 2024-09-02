import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId = dotenv.env['771bff311f67481ca6e1a692fc72e74c']!;
  final String clientSecret = dotenv.env['3aae08644a824b0fbf0663744b3ee63c']!;
  String? accessToken;

  // Authenticate with Spotify API
  Future<void> authenticate() async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      accessToken = data['access_token'];
    } else {
      throw Exception('Failed to authenticate with Spotify');
    }
  }

  // Fetch a list of genres available for recommendations
  Future<List<String>> fetchGenres() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/recommendations/available-genre-seeds'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<String> genres = (data['genres'] as List)
          .map((genre) => genre as String)
          .toList();
      return genres;
    } else {
      throw Exception('Failed to fetch genres');
    }
  }

  // Fetch a list of artists based on selected genres
  Future<List<String>> fetchArtists(List<String> genres) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=${genres.join('%20')}&type=artist'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<String> artists = (data['artists']['items'] as List)
          .map((artist) => artist['name'] as String)
          .toList();
      return artists;
    } else {
      throw Exception('Failed to fetch artists');
    }
  }

  // Fetch recommended artists based on selected artists
  Future<List<String>> fetchRecommendationsArtists(List<String> artists) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/recommendations?seed_artists=${artists.join('%2C')}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<String> recommendations = (data['tracks'] as List)
          .map((track) => track['name'] as String)
          .toList();
      return recommendations;
    } else {
      throw Exception('Failed to fetch recommendations');
    }
  }


}
