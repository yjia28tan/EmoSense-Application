import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:emosense/api_services/spotify_services.dart';

class ArtistSelectionPage extends StatefulWidget {
  final SpotifyService spotifyService;
  final List<String> selectedGenres;

  ArtistSelectionPage({required this.spotifyService, required this.selectedGenres});

  @override
  _ArtistSelectionPageState createState() => _ArtistSelectionPageState();
}

class _ArtistSelectionPageState extends State<ArtistSelectionPage> {
  late SpotifyService spotifyService;
  List<Artist> artists = [];
  List<String> selectedArtists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    spotifyService = widget.spotifyService;
    fetchArtists();
  }

  void fetchArtists() async {
    try {
      // Authenticate with Spotify
      await spotifyService.authenticate();

      List<Artist> allArtists = [];
      for (String genre in widget.selectedGenres) {
        try {
          // Fetch artists for the current genre
          List<Artist> fetchedArtists = await spotifyService.getArtistsForGenres([genre]);
          print("Fetched ${fetchedArtists.length} artists for genre: $genre");

          // Add fetched artists to the list
          allArtists.addAll(fetchedArtists);
        } catch (e) {
          print('Error fetching artists for genre $genre: $e');
        }
      }

      // Remove duplicates if needed
      allArtists = allArtists.toSet().toList();

      // Update the state with fetched artists
      setState(() {
        artists = allArtists;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSimilarArtists(String artistId) async {
    try {
      // Fetch similar artists for the given artist
      List<Artist> similarArtists = await spotifyService.getSimilarArtists(artistId);

      // Filter out artists that are already in the list
      similarArtists = similarArtists.where((artist) => !artists.any((existing) => existing.id == artist.id)).toList();

      // Update the state with similar artists
      setState(() {
        artists.addAll(similarArtists);
      });
    } catch (e) {
      print('Error fetching similar artists for artist $artistId: $e');
    }
  }

  void toggleArtistSelection(String artistId) {
    setState(() {
      if (selectedArtists.contains(artistId)) {
        selectedArtists.remove(artistId);
      } else {
        selectedArtists.add(artistId);
      }
    });
  }

  Future<void> savePreferencesToFirebase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a list of artist details to save
      List<Map<String, dynamic>> artistDetails = artists
          .where((artist) => selectedArtists.contains(artist.id))
          .map((artist) => {
        'id': artist.id,
        'name': artist.name,
        'imageUrl': artist.imageUrl,
        // 'genres': artist.genres, // Add other relevant fields if needed
      })
          .toList();

      // Create a new document in the "preferences" collection with the UID as a foreign key
      await firestore.collection('preferences').add({
        'uid': globalUID,
        'selectedGenres': widget.selectedGenres,
        'selectedArtists': artistDetails, // Save detailed artist info
      });

      print("Preferences saved successfully!");
    } catch (e) {
      print("Error saving preferences: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Your Favorite Artists"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show a loader while fetching data
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of items per row
            childAspectRatio: 1, // Keep items square
          ),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            final isSelected = selectedArtists.contains(artist.id);

            return GestureDetector(
              onTap: () async {
                toggleArtistSelection(artist.id);

                if (!isSelected) {
                  // Fetch and add similar artists when selecting an artist
                  await fetchSimilarArtists(artist.id);
                }
              },
              child: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (artist.imageUrl.isNotEmpty)
                      Image.network(artist.imageUrl, height: 50),
                    Text(
                      artist.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            // Save preferences to Firebase
            await savePreferencesToFirebase();

            // Navigate to Home Page
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          },
          child: Text("Done"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
        ),
      ),
    );
  }
}
