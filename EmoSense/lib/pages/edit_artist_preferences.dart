import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/main.dart';
import 'package:flutter/material.dart';
import 'package:emosense/api_services/spotify_services.dart';

class EditArtistPreferencesPage extends StatefulWidget {
  final SpotifyService spotifyService;
  final List<String> selectedArtists;

  EditArtistPreferencesPage({required this.spotifyService, required this.selectedArtists});

  @override
  _EditArtistPreferencesPageState createState() => _EditArtistPreferencesPageState();
}

class _EditArtistPreferencesPageState extends State<EditArtistPreferencesPage> {
  late SpotifyService spotifyService;
  List<Artist> artists = [];
  List<String> selectedArtists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    spotifyService = widget.spotifyService;
    selectedArtists = widget.selectedArtists;
    fetchArtists();
  }

  void fetchArtists() async {
    try {
      await spotifyService.authenticate();
      List<Artist> fetchedArtists = await spotifyService.getArtistsForGenres([]);

      setState(() {
        artists = fetchedArtists;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching artists: $e');
      setState(() {
        isLoading = false;
      });
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

  Future<void> saveUpdatedPreferences() async {
    try {
      // Update user preferences in Firestore
      await FirebaseFirestore.instance
          .collection('preferences')
          .where('uid', isEqualTo: globalUID)
          .get()
          .then((snapshot) {
        snapshot.docs.first.reference.update({
          'selectedArtists': selectedArtists,
        });
      });

      print("Preferences updated successfully!");
    } catch (e) {
      print("Error updating preferences: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Artist Preferences"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selected Artists",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                ),
                itemCount: selectedArtists.length,
                itemBuilder: (context, index) {
                  final artist = artists.firstWhere((a) => a.id == selectedArtists[index]);
                  return GestureDetector(
                    onTap: () => toggleArtistSelection(artist.id),
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.purple,
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
                              color: Colors.white,
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
            Text(
              "Other Artists",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                ),
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  if (selectedArtists.contains(artist.id)) return Container(); // Skip selected artists
                  return GestureDetector(
                    onTap: () => toggleArtistSelection(artist.id),
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
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
                              color: Colors.black,
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Handle saving preferences
            // Save preferences to Firebase, etc.
          },
          child: Text("Save Preferences"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
        ),
      ),
    );
  }
}
