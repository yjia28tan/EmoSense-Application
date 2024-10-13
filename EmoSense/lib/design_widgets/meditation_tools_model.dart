class MeditationTool {
  final String title;
  final String backgroundImage; // Add the backgroundImage property

  MeditationTool({
    required this.title,
    required this.backgroundImage,
  });
}

// List of tools
final List<MeditationTool> meditationTools = [
  MeditationTool(
    title: 'Mindfulness meditation',
    backgroundImage: 'assets/discover/meditation.jpg',
  ),
  MeditationTool(
    title: 'Breathing exercise',
    backgroundImage: 'assets/discover/breathing.jpg',
  ),
  MeditationTool(
    title: 'Sleeping guide',
    backgroundImage: 'assets/discover/sleep.jpg',
  ),
  MeditationTool(
    title: 'Stress relief',
    backgroundImage: 'assets/discover/relief.jpg',
  ),
];