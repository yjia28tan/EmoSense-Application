import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/custom_loading_button.dart';
import 'package:emosense/design_widgets/font_style.dart';
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
  // List<Artist> selectedArtists = [];
  List<String> favouriteGenres = [];
  bool isLoading = true;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    spotifyService = SpotifyService();
    fetchPreferencesFromFirestore();
    fetchArtists();
  }

  void fetchPreferencesFromFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('preferences')
          .where('uid', isEqualTo: widget.uid)
          .get()
          .then((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          setState(() {
            selectedArtists = List<String>.from(data['selectedArtists'].map((artist) => artist['id']));
            favouriteGenres = List<String>.from(data['selectedGenres']);
          });

          // Fetch artist details based on the selected artist IDs
          // await fetchArtistsFromSpotify(selectedArtist);
        }
      });
    } catch (e) {
      print("Error fetching favourite artists: $e");
    }
  }

  void fetchArtists() async {
    try {
      await spotifyService.authenticate();

      List<Artist> allArtists = [];
      for (String genre in favouriteGenres) {
        try {
          List<Artist> fetchedArtists = await spotifyService.getArtistsForGenres([genre]);
          allArtists.addAll(fetchedArtists);
        } catch (e) {
          print('Error fetching artists for genre $genre: $e');
        }
      }

      allArtists = allArtists.toSet().toList();

      setState(() {
        // Append more artists without duplicating the already selected ones
        artists.addAll(allArtists.where((artist) => !selectedArtists.contains(artist.id)).toList());
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
      await spotifyService.authenticate();
      List<Artist> similarArtists = await spotifyService.getSimilarArtists(artistId);

      similarArtists = similarArtists.where((artist) => !artists.any((existing) => existing.id == artist.id)).toList();

      setState(() {
        artists.addAll(similarArtists);
      });
    } catch (e) {
      print('Error fetching similar artists for artist $artistId: $e');
    }
  }

  Future<void> searchArtists(String query) async {
    try {
      await spotifyService.authenticate();
      List<Artist> searchResults = await spotifyService.searchArtists(query);
      setState(() {
        artists = searchResults;
      });
    } catch (e) {
      print('Error searching for artists: $e');
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

      // Create a list of selected artist details
      List<Map<String, dynamic>> artistDetails = artists
          .where((artist) => selectedArtists.contains(artist.id))
          .map((artist) => {
        'id': artist.id,
        'name': artist.name,
        'imageUrl': artist.imageUrl,
      })
          .toList();

      print("selected artists: $artistDetails");

      // Fetch the document using the UID to ensure it's the correct user
      QuerySnapshot snapshot = await firestore
          .collection('preferences')
          .where('uid', isEqualTo: widget.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Get the document reference and update it
        DocumentReference docRef = snapshot.docs.first.reference;

        // Update the selectedArtists field in the document
        await docRef.update({
          'selectedArtists': artistDetails,
        });

        print("Preferences updated successfully!");
      } else {
        // If no document exists for this user, create a new one
        await firestore.collection('preferences').add({
          'uid': widget.uid,  // Use widget.uid instead of globalUID if that's correct
          'selectedArtists': artistDetails,
        });

        print("New preferences document created successfully!");
      }
    } catch (e) {
      print("Error saving preferences: $e");
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
          ? Center(child: CustomLoadingIndicator())
          : Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 15.0, bottom: 15.0),
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10.0, right: 10.0, bottom: 10.0),
              child: TextField(
                style: textBlackNormal.copyWith(fontSize: 16),
                onChanged: (query) {
                  searchTerm = query;
                  searchArtists(query); // Perform search as the user types
                },
                decoration: InputDecoration(
                  hintText: 'Search artists',
                  hintStyle: greySmallText.copyWith(fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: AppColors.textColorBlack, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                ),
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  // Separate the selected artists from the unselected artists
                  final selectedArtistsList = artists.where((artist) => selectedArtists.contains(artist.id)).toList();
                  final unselectedArtistsList = artists.where((artist) => !selectedArtists.contains(artist.id)).toList();

                  // Combine the selected and unselected lists
                  final combinedArtists = [...selectedArtistsList, ...unselectedArtistsList];

                  // Fetch the current artist
                  final artist = combinedArtists[index];
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
              padding: const EdgeInsets.only(left: 15.0, right: 15, top: 10, bottom: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPurpleColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  savePreferencesToFirebase(); // Update preferences in Firebase
                  // Show updated snackbar for 2 seconds
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Preferences updated successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Navigate back to the HomePage and set the selected index to 4 (Profile Page)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(selectedIndex: 4)),
                  );
                },
                child: Text(
                  "Save",
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
