import 'dart:convert';
import 'dart:math';
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

  /// Fetch recommended songs based on selected genres, artists, and detected emotion
  Future<List<String>> searchPlaylists(String query) async {
    try {
      final url = 'https://api.spotify.com/v1/search?q=$query&type=playlist&limit=5';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final playlists = data['playlists']['items'] as List;

        return playlists.map((playlist) => playlist['id'] as String).toList();
      } else {
        throw Exception('Failed to search playlists: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error searching playlists: $e');
      throw Exception('Error searching playlists: $e');
    }
  }

  /// Fetch tracks from a list of playlist IDs
  Future<List<Track>> fetchTracksFromPlaylists(List<String> playlistIds) async {
    try {
      final tracks = <Track>[];

      for (String playlistId in playlistIds) {
        final url = 'https://api.spotify.com/v1/playlists/$playlistId/tracks';

        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final items = data['items'] as List;
          for (var item in items) {
            final trackData = item['track'];
            if (trackData != null) {
              tracks.add(Track.fromJson(trackData));
            }
          }
        } else {
          throw Exception('Failed to fetch tracks: ${response.statusCode} - ${response.body}');
        }
      }

      // Remove duplicates
      final uniqueTracks = tracks.toSet().toList();

      // Return a limited number of tracks (3 to 15)
      final random = new Random();
      uniqueTracks.shuffle(random); // Shuffle the list to randomize selection
      return uniqueTracks.take(15).toList(); // Limit to 15 songs or less
    } catch (e) {
      print('Error fetching tracks: $e');
      throw Exception('Error fetching tracks: $e');
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

class Track {
  final String id;
  final String name;
  final String artist;
  final String imageUrl;
  final String album;
  final String spotifyUrl; // Spotify link to play the track

  Track({
    required this.id,
    required this.name,
    required this.artist,
    required this.imageUrl,
    required this.album,
    required this.spotifyUrl,
  });

  // Factory constructor to create Track from JSON data
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? '', // Default to an empty string if id is null
      name: json['name'] ?? 'Unknown Track', // Default to 'Unknown Track' if name is null
      artist: (json['artists'] as List).isNotEmpty
          ? json['artists'][0]['name'] ?? 'Unknown Artist'
          : 'Unknown Artist', // Check if artist list is not empty and has valid data
      imageUrl: (json['album'] != null && json['album']['images'] != null && (json['album']['images'] as List).isNotEmpty)
          ? json['album']['images'][0]['url'] ?? ''
          : '', // Handle null imageUrl or missing album field
      album: json['album'] != null ? json['album']['name'] ?? 'Unknown Album' : 'Unknown Album', // Handle null album field
      spotifyUrl: json['external_urls'] != null && json['external_urls']['spotify'] != null
          ? json['external_urls']['spotify']
          : '', // Ensure the Spotify URL is not null
    );
  }
}
