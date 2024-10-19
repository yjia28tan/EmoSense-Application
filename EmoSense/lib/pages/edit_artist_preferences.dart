import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:emosense/api_services/spotify_services.dart';

class EditArtistPreferencesPage extends StatefulWidget {
  final uid;

  EditArtistPreferencesPage({required this.uid});

  @override
  _EditArtistPreferencesPageState createState() => _EditArtistPreferencesPageState();
}

class _EditArtistPreferencesPageState extends State<EditArtistPreferencesPage> {
  late SpotifyService spotifyService;
  List<Artist> artists = [];
  List<String> selectedArtists = [];
  List<String> favouriteGenres = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    spotifyService = SpotifyService(); // Initialize your Spotify service here
    fetchArtists();
    fetchFavouriteArtistsNGenres();
  }

  void fetchFavouriteArtistsNGenres() async {
    try {
      await FirebaseFirestore.instance
          .collection('preferences')
          .where('uid', isEqualTo: widget.uid)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          setState(() {
            selectedArtists = List<String>.from(data['selectedArtists'].map((artist) => artist['id']));
            print("Selected artists: $selectedArtists");
            favouriteGenres = List<String>.from(data['selectedGenres']);
            print("Favourite genres: $favouriteGenres" );
          });
        }
      });
    } catch (e) {
      print("Error fetching favourite artists: $e");
    }
  }

  void fetchArtists() async {
    try {
      await spotifyService.authenticate();
      // Fetch artists based on previously selected genres if needed
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

  Future<void> fetchSimilarArtists(String artistId) async {
    try {
      List<Artist> similarArtists = await spotifyService.getSimilarArtists(artistId);
      similarArtists = similarArtists.where((artist) => !artists.any((existing) => existing.id == artist.id)).toList();
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
      List<Map<String, dynamic>> artistDetails = artists
          .where((artist) => selectedArtists.contains(artist.id))
          .map((artist) => {
        'id': artist.id,
        'name': artist.name,
        'imageUrl': artist.imageUrl,
      })
          .toList();

      await firestore.collection('preferences').doc(widget.uid).update({
        'selectedArtists': artistDetails,
      });

      print("Preferences updated successfully!");
    } catch (e) {
      print("Error updating preferences: $e");
    }
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
            'Edit Favourite Artists',
            style: ProfileTitleText,
          ),
        ),
        actions: [
          Container(width: 48),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 15.0, bottom: 15.0),
            child: Column(
              children: [
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
                                    maxWidth: 80,
                                    minHeight: 1,
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
                  padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
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
                      // Navigate back to the HomePage and set the selected index to 4 (Profile Page)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(selectedIndex: 4)),
                      );
                    },
                    child: Text(
                      "Save Preferences",
                      style: whiteText,
                      ),
                    ),
                ),
          ],
        ),
      ),
    );
  }
}
