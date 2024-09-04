import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/pages/artists_selection_page.dart';
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
      appBar: AppBar(
        title: Text("Select Your Favorite Genres"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show a loader while fetching data
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of items per row
            childAspectRatio: 1, // Keep items square
          ),
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];
            final isSelected = selectedGenres.contains(genre);

            return GestureDetector(
              onTap: () => toggleGenreSelection(genre),
              child: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    genre,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the next page with selected genres
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtistSelectionPage(
                  spotifyService: spotifyService, // Pass the SpotifyService instance
                  selectedGenres: selectedGenres,
                ),
              ),
            );
          },
          child: Text("Next"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
        ),
      ),
    );
  }
}
