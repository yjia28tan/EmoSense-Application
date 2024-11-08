import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/custom_loading_button.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:emosense/api_services/spotify_services.dart';

class ArtistSelectionPage extends StatefulWidget {
  final SpotifyService spotifyService;
  final List<String> selectedGenres;
  final List<String> emotionGenreMap;

  ArtistSelectionPage({required this.spotifyService, required this.selectedGenres, required this.emotionGenreMap});

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
      await spotifyService.authenticate();

      // SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetching artists from Spotify...')),
      );


      List<Artist> allArtists = [];
      for (String genre in widget.selectedGenres) {
        try {
          List<Artist> fetchedArtists = await spotifyService.getArtistsForGenres([genre]);
          allArtists.addAll(fetchedArtists);
        } catch (e) {
          print('Error fetching artists for genre $genre: $e');
          // Show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching artists for genre: $e')),
          );
        }
      }

      allArtists = allArtists.toSet().toList();

      setState(() {
        artists = allArtists;
        isLoading = false;
      });
    } catch (e) {
      // SnackBar show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch artists: $e')),
      );
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSimilarArtists(String artistId) async {
    try {
      List<Artist> similarArtists = await spotifyService.getSimilarArtists(artistId);

      similarArtists = similarArtists.where((artist) => !artists.any((existing) => existing.id == artist.id)).toList();

      setState(() {
        artists.addAll(similarArtists);
      });
    } catch (e) {
      // SnackBar show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch similar artists: $e')),
      );
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

      List<Map<String, dynamic>> artistDetails = artists
          .where((artist) => selectedArtists.contains(artist.id))
          .map((artist) => {
        'id': artist.id,
        'name': artist.name,
        'imageUrl': artist.imageUrl,
      })
          .toList();

      await firestore.collection('preferences').add({
        'uid': globalUID,
        'selectedGenres': widget.selectedGenres,
        'selectedArtists': artistDetails,
        'emotionGenreMap': widget.emotionGenreMap,
      });

      print("Preferences saved successfully!");

    } catch (e) {
      // SnackBar show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error to save preferences: $e')),
      );
      print("Error saving preferences: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.downBackgroundColor,
      body: isLoading
          ? Center(child: CustomLoadingIndicator())
          : Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 15.0, bottom: 15.0),
            child: Column(
              children: [
                SizedBox(height: 30),
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_outlined,
                            color: AppColors.textColorBlack),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    Text(
                        "Choose the artist you like.",
                        style: titleBlack,
                        textAlign: TextAlign.center,
                    ),

                    SizedBox(width: 8),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                    ),
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      final isSelected = selectedArtists.contains(artist.id);

                      return GestureDetector(
                        onTap: () async {
                          toggleArtistSelection(artist.id);

                          if (!isSelected) {
                            await fetchSimilarArtists(artist.id);
                          }
                        },
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppColors.darkPurpleColor
                                        : AppColors.textFieldColor,
                                  ),
                                  child: CircleAvatar(
                                    backgroundImage: artist.imageUrl.isNotEmpty
                                        ? NetworkImage(artist.imageUrl)
                                        : null,
                                    radius: 40,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: 80,  // Adjust the width as needed
                                    minHeight: 1,  // Adjust height to give more room for text
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      artist.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? AppColors.darkPurpleColor
                                            : AppColors.textColorBlack,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              Positioned(
                                right: 1,
                                top: 1,
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.darkPurpleColor,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 10
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPurpleColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      await savePreferencesToFirebase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Preferences Saved Successfully!"),
                        ),
                      );
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    child: Text(
                      "Done",
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
