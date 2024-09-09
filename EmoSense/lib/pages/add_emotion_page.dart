import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class EmotionDetectionPage extends StatefulWidget {
  @override
  _EmotionDetectionPageState createState() => _EmotionDetectionPageState();
}

class _EmotionDetectionPageState extends State<EmotionDetectionPage> {
  List<String> _labels = [];
  XFile? _image;
  String _detectedEmotion = 'No emotion detected';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    // Load your model and labels
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
    final labels = await loadLabels('assets/labels.txt');
    setState(() {
      _labels = labels;
    });
  }

  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = image;
      });
      _predictEmotion(image);
    }
  }

  Future<void> _predictEmotion(XFile image) async {
    final imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      final resizedImage = img.copyResize(decodedImage, width: 48, height: 48);
      final imgBytes = img.encodeJpg(resizedImage);

      final output = await Tflite.runModelOnBinary(
        binary: Uint8List.fromList(imgBytes),
        numResults: 7,
        threshold: 0.1,
      );

      if (output != null) {
        final index = output
            .map((e) => e['confidence'] as double)
            .toList()
            .indexOf(output.map((e) => e['confidence'] as double).reduce((a, b) => a > b ? a : b));

        setState(() {
          _detectedEmotion = _labels[index];
        });
      } else {
        setState(() {
          _detectedEmotion = 'No output from model';
        });
      }
    } else {
      setState(() {
        _detectedEmotion = 'Failed to decode image';
      });
    }
  }

  Future<List<String>> loadLabels(String path) async {
    final labels = await DefaultAssetBundle.of(context).loadString(path);
    return labels.split('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Emotion Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text('No image selected.')
                : Image.file(File(_image!.path)),
            Text(_detectedEmotion),
            ElevatedButton(
              onPressed: _captureImage,
              child: Text('Capture Image'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => RecommendationPage(emotion: _detectedEmotion),
                //   ),
                // );
              },
              child: Text('Get Recommendations'),
            ),
          ],
        ),
      ),
    );
  }
}
