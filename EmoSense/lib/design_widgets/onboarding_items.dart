import 'package:emosense/design_widgets/onboarding_model.dart';

class OnboardingItems{
  List<OnboardingModel> items = [
    OnboardingModel(
        title: "Welcome to EmoSense",
        descriptions: "Your companion in emotional well-being.",
        image: "assets/onboarding/welcome.png"),

    OnboardingModel(
        title: "Emotion Detection",
        descriptions: "To know how you’re feeling.",
        image: "assets/onboarding/detect.png"),

    OnboardingModel(
        title: "Music Recommendations",
        descriptions: "Provide personalised music based on your emotion.",
        image: "assets/onboarding/music.png"),

    OnboardingModel(
        title: "Discover",
        descriptions: "Guided meditations for emotional regulation, stress relief and overall well-being.",
        image: "assets/onboarding/discover.png"),

    OnboardingModel(
        title: "You’re all set!",
        descriptions: "Let’s start your journey to emotional balance.",
        image: "assets/onboarding/set.png"),

  ];
}