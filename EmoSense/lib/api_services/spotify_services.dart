import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId = '771bff311f67481ca6e1a692fc72e74c';
  final String clientSecret = '3aae08644a824b0fbf0663744b3ee63c';
  String? accessToken;

  /// Authenticate with Spotify API
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

  /// Fetch available genres from Spotify
  Future<List<String>> getAvailableGenres() async {
    const url = 'https://api.spotify.com/v1/recommendations/available-genre-seeds';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Genres: $data");
      return List<String>.from(data['genres']);
    } else {
      throw Exception('Failed to load genres');
    }
  }

  /// Fetch artists based on selected genres
  Future<List<Artist>> getArtistsForGenres(List<String> genres) async {
    const limit = 50; // Limit the number of artists fetched
    final genreString = genres.join(',');

    final url = 'https://api.spotify.com/v1/search?q=genre:$genreString&type=artist&limit=$limit';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final artists = data['artists']['items'] as List;
      print(data);
      return artists.map((artistData) => Artist.fromJson(artistData)).toList();
    } else {
      throw Exception('Failed to load artists');
    }
  }

  /// Fetch similar artists for a given artist
  Future<List<Artist>> getSimilarArtists(String artistId) async {
    // Limit the number of similar artists fetched
    const limit = 5;

    if (accessToken == null) {
      throw Exception('Access token is not set');
    }

    final url = 'https://api.spotify.com/v1/artists/$artistId/related-artists?limit=$limit';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final artists = data['artists'] as List;
      return artists.map((artistData) => Artist.fromJson(artistData)).toList();
    } else {
      throw Exception('Failed to load similar artists for artist $artistId');
    }
  }

}

// Model class for Artist
class Artist {
  final String id;
  final String name;
  final String imageUrl;

  Artist({required this.id, required this.name, required this.imageUrl});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['url']
          : '',
    );
  }
}

// Model class for Track
class Track {
  final String id;
  final String name;
  final String artist;
  final String imageUrl;

  Track({required this.id, required this.name, required this.artist, required this.imageUrl});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      artist: json['artists'][0]['name'],
      imageUrl: json['album']['images'] != null && json['album']['images'].isNotEmpty
          ? json['album']['images'][0]['url']
          : '',
    );
  }
}