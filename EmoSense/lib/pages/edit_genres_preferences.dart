import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/custom_loading_button.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/edit_genre_survey_page.dart';
import 'package:flutter/material.dart';
import 'package:emosense/api_services/spotify_services.dart';

class EditGenrePreferencesPage extends StatefulWidget {
  final uid;

  EditGenrePreferencesPage({required this.uid});

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
    spotifyService = SpotifyService(); // Initialize SpotifyService correctly
    fetchFavouriteGenres(); // Fetch user-selected genres
    fetchGenres(); // Fetch available genres from Spotify
  }

  void fetchFavouriteGenres() async {
    try {
      await FirebaseFirestore.instance
          .collection('preferences')
          .where('uid', isEqualTo: globalUID)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          setState(() {
            selectedGenres = List<String>.from(data['selectedGenres']);
          });
        }
      });
    } catch (e) {
      print("Error fetching favourite genres: $e");
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching favourite genres: $e')),
      );
    }
  }

  void fetchGenres() async {
    try {
      await spotifyService.authenticate();

      // SnackBar for 1 second
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetching genres from Spotify...'), duration: Duration(seconds: 1)
        ),
      );


      List<String> fetchedGenres = await spotifyService.getAvailableGenres();

      setState(() {
        genres = fetchedGenres;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching genres: $e');
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching genres: $e')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.darkLogoColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.textFieldColor,
        title: Container(
          alignment: Alignment.center,
          child: Text(
            'Edit Favourite Genres',
            style: ProfileTitleText,
          ),
        ),
        actions: [
          Container(width: 48),
        ],
      ),
      body: isLoading
          ? Center(child: CustomLoadingIndicator())
          : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selected Genres",
                  style: titleBlack,
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 2,
                    ),
                    itemCount: selectedGenres.length,
                    itemBuilder: (context, index) {
                      final genre = selectedGenres[index];
                      return GestureDetector(
                        onTap: () => toggleGenreSelection(genre),
                        child: Container(
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: AppColors.darkPurpleColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              genre,
                              style: whiteText.copyWith(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  "Other Genres",
                  style: titleBlack,
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 2,
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
                              style: titleBlack.copyWith(fontSize: 16),
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
        padding: const EdgeInsets.symmetric(
            vertical: 15.0, horizontal: 10
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPurpleColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            minimumSize: Size(double.infinity, 50), // Full-width button
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditEmotionGenreSurveyPage(
                    spotifyService: spotifyService,
                    selectedGenres: selectedGenres),
              ),
            );
          },
          child: Text(
            "Next",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
