import 'package:flutter/material.dart';

class PreferencesSurveyPage extends StatefulWidget {
  static String routeName = '/PreferencesSurveyPage';

  const PreferencesSurveyPage({Key? key}) : super(key: key);

  @override
  State<PreferencesSurveyPage> createState() => _PreferencesSurveyPageState();
}

class _PreferencesSurveyPageState extends State<PreferencesSurveyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preferences Survey')),
      body: Center(
        child: Text('Survey Page Content'),
      ),
    );
  }
}

