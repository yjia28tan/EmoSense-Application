import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/pages/artists_selection_page.dart';
import 'package:emosense/pages/emotion_genre_survey_page.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:flutter/material.dart';

class GenreSelectionPage extends StatefulWidget {
  static String routeName = '/GenreSelectionPage';

  @override
  _GenreSelectionPageState createState() => _GenreSelectionPageState();
}

class _GenreSelectionPageState extends State<GenreSelectionPage> {
  late SpotifyService spotifyService;
  List<String> genres = [];
  List<String> selectedGenres = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    spotifyService = SpotifyService();
    authenticateAndFetchGenres();
  }

  void authenticateAndFetchGenres() async {
    try {
      // Authenticate with Spotify
      await spotifyService.authenticate();

      // Fetch available genres
      List<String> fetchedGenres = await spotifyService.getAvailableGenres();

      // Update the state with fetched genres
      setState(() {
        genres = fetchedGenres;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
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
      backgroundColor: AppColors.downBackgroundColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show a loader while fetching data
          : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                SizedBox(height: 30),
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                      ),
                    ),
                    Text(
                      "What music do you like?",
                      style: titleBlack,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: genres.isEmpty
                      ? Center(child: Text("No genres found"))
                      : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 2, // Ensures square buttons
                        ),
                        itemCount: genres.length,
                        itemBuilder: (context, index) {
                          final genre = genres[index];
                          final isSelected = selectedGenres.contains(genre);

                          return GestureDetector(
                            onTap: () => toggleGenreSelection(genre),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.darkPurpleColor
                                    : AppColors.textFieldColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      genre,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textColorBlack,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
                Padding(
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
                          builder: (context) => EmotionGenreSurveyPage(
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
              ],
            ),
          ),
    );
  }
}
