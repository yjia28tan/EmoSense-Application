import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/main.dart';
import 'package:flutter/material.dart';
import 'package:emosense/api_services/spotify_services.dart';

class EditGenrePreferencesPage extends StatefulWidget {
  final SpotifyService spotifyService;
  final List<String> selectedGenres;

  EditGenrePreferencesPage({required this.spotifyService, required this.selectedGenres});

  @override
  _EditGenrePreferencesPageState createState() => _EditGenrePreferencesPageState();
}

class _EditGenrePreferencesPageState extends State<EditGenrePreferencesPage> {
  late SpotifyService spotifyService;
  List<String> genres = [];
  List<String> selectedGenres = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    spotifyService = widget.spotifyService;
    selectedGenres = widget.selectedGenres;
    fetchGenres();
  }

  void fetchGenres() async {
    try {
      await spotifyService.authenticate();
      List<String> fetchedGenres = await spotifyService.getAvailableGenres();

      setState(() {
        genres = fetchedGenres;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching genres: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleGenreSelection(String genre) {
    setState(() {
      if (selectedGenres.contains(genre)) {
        selectedGenres.remove(genre);
      } else {
        selectedGenres.add(genre);
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
          'selectedGenres': selectedGenres,
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
        title: Text("Edit Genre Preferences"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selected Genres",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: selectedGenres.length,
                    itemBuilder: (context, index) {
                      final genre = selectedGenres[index];
                      return GestureDetector(
                        onTap: () => toggleGenreSelection(genre),
                        child: Container(
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              genre,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  "Other Genres",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: genres.length,
                    itemBuilder: (context, index) {
                      final genre = genres[index];
                      if (selectedGenres.contains(genre)) return Container(); // Skip selected genres
                      return GestureDetector(
                        onTap: () => toggleGenreSelection(genre),
                        child: Container(
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              genre,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
