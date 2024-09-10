import 'package:camera/camera.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class EmotionDetectionPage extends StatefulWidget {
  static String routeName = '/EmotionDetectionPage';

  @override
  _EmotionDetectionPageState createState() => _EmotionDetectionPageState();
}

class _EmotionDetectionPageState extends State<EmotionDetectionPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription>? cameras;
  String errorMessage = '';
  bool isFrontCamera = false;
  bool isFlashOn = false;
  String detectedEmotion = '';
  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    PermissionStatus cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      try {
        // Get available cameras
        cameras = await availableCameras();

        // Initialize the camera controller
        _controller = CameraController(
          cameras![isFrontCamera ? 1 : 0], // Use front camera if isFrontCamera is true
          ResolutionPreset.high,
        );

        _initializeControllerFuture = _controller!.initialize();
        setState(() {});
      } catch (e) {
        // Handle camera initialization error
        setState(() {
          errorMessage = 'Error initializing camera: $e';
        });
      }
    } else {
      // Handle permission denial
      setState(() {
        errorMessage = 'Camera permission denied';
      });
    }
  }

  Future<void> _loadModel() async {
    // Load the model
    try {
    _interpreter = await Interpreter.fromAsset('model.tflite');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> _processImage(String imagePath) async {
    // Load the image and preprocess it (resize, normalize, etc.)
    // Assume that _preprocessImage returns a properly formatted input tensor
    var input = await _preprocessImage(imagePath);

    // Run inference
    var output = List.filled(1 * 6, 0).reshape([1, 6]); // Adjust shape according to your model
    _interpreter.run(input, output);

    // Process output
    setState(() {
      detectedEmotion = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b)).toString(); // Example
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : _controller == null
                      ? Center(child: CircularProgressIndicator())
                      : FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return CameraPreview(_controller!);
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                  if (detectedEmotion.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      right: 100,
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Emotion: $detectedEmotion',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 35.0, left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: AppColors.darkPurpleColor,
                    ),
                    onPressed: () async {
                      if (_controller != null) {
                        setState(() {
                          isFlashOn = !isFlashOn;
                        });
                        await _controller!.setFlashMode(
                            isFlashOn ? FlashMode.torch : FlashMode.off);
                      }
                    },
                  ),
                  FloatingActionButton(
                    // set shape round
                    shape: CircleBorder(),
                    backgroundColor: AppColors.darkLogoColor,
                    onPressed: () async {
                      try {
                        await _initializeControllerFuture;
                        final image = await _controller!.takePicture();
                        await _processImage(image.path);
                        print('Picture saved to: ${image.path}');
                        // here process the image and detect the emotion

                      } catch (e) {
                        setState(() {
                          errorMessage = 'Error taking picture: $e';
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.change_circle_rounded,
                      color: AppColors.darkPurpleColor,
                    ),
                    onPressed: () async {
                      setState(() {
                        isFrontCamera = !isFrontCamera;
                      });
                      await _initializeCamera();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // image preprocessing function
  Future<Uint8List> _preprocessImage(String imagePath) async {
    // Load the image file
    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize the image to the expected input size of the model
    final resizedImage = img.copyResize(image, width: 48, height: 48); // Change to your model's expected size

    // Convert the image to a list of floats
    final byteData = resizedImage.getBytes();
    final floatList = Float32List.fromList(byteData.map((byte) => byte.toDouble() / 255.0).toList());

    // Add batch dimension
    final processedImage = Float32List.fromList(
      List.generate(
        floatList.length + 1,
            (i) => i == 0 ? 1.0 : floatList[i - 1], // Add batch dimension with value 1.0
      ),
    );

    return processedImage.buffer.asUint8List();
  }

}
