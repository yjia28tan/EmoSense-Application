import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/pages/current_emotion_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

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
  bool isFrontCamera = true;
  bool isFlashOn = false;
  String detectedEmotion = '';
  File? _capturedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _initializeCamera();
    });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            duration: Duration(seconds: 3), // Show SnackBar for 3 seconds
          ),
        );
        print('Error initializing camera: $e');
      }
    } else {
      // Handle permission denial
      setState(() {
        errorMessage = 'Camera permission denied';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera permission denied'),
          duration: Duration(seconds: 3), // Show SnackBar for 3 seconds
        ),
      );
      print('Camera permission denied');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    if (imageFile == null || imageFile.path.isEmpty) {
      setState(() {
        errorMessage = 'Error: Image file is null or empty.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Image file is null or empty.'),
          duration: Duration(seconds: 3), // Show SnackBar for 3 seconds
        ),
      );
      return;
    }

    final uri = Uri.parse('http://192.168.158.34:5000/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      setState(() {
        detectedEmotion = jsonResponse['detected_emotion'] ?? 'Unknown Emotion';
        print(detectedEmotion);
        // Show the detected emotion using SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Detected Emotion: $detectedEmotion'),
            duration: Duration(seconds: 1), // Show SnackBar for 3 seconds
          ),
        );
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error uploading image: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          duration: Duration(seconds: 3), // Show SnackBar for 3 seconds
        ),
      );
    }
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
                  _controller == null
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
                  if (_capturedImage != null)
                    Positioned.fill(
                      child: Center(
                        child: Image.file(
                          _capturedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (_capturedImage != null) // Only show if an image is captured
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: Icon(Icons.close, color: AppColors.downBackgroundColor, size: 30),
                        onPressed: () {
                          setState(() {
                            _capturedImage = null; // Reset captured image
                            isLoading = false; // Stop loading
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 5.0, left: 8.0, right: 8.0),
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
                        try {
                          await _controller!.setFlashMode(
                              isFlashOn ? FlashMode.torch : FlashMode.off);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error toggling flash mode: $e'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  FloatingActionButton(
                    shape: CircleBorder(),
                    backgroundColor: AppColors.darkLogoColor,
                    child: isLoading
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Icon(
                      _capturedImage == null ? Icons.camera_alt : Icons.check,
                      color: Colors.white,
                    ),
                    onPressed: isLoading ? null : () async {
                      if (_capturedImage == null) {
                        // Capture image logic
                        try {
                          await _initializeControllerFuture;
                          final image = await _controller!.takePicture();
                          print('Picture saved to: ${image.path}');

                          setState(() {
                            _capturedImage = File(image.path);
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error taking picture: $e'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } else {
                        // If image captured, upload it
                        try {
                          setState(() {
                            isLoading = true; // Start loading
                          });
                          await _uploadImage(_capturedImage!);

                          if (detectedEmotion.isNotEmpty) {
                            setState(() {
                              isLoading = false; // Stop loading
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmotionConfirmationPage(
                                  detectedEmotion: detectedEmotion,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            isLoading = false; // Stop loading in case of error
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error uploading image: $e'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
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
                  // X Button to discard the image

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
