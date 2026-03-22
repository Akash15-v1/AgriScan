import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../helpers/classifier.dart';
import '../screens/result_screen.dart';

class CameraScreen extends StatefulWidget {
  final String language;

  const CameraScreen({Key? key, required this.language}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  final Classifier _classifier = Classifier();
  bool _isLoading = false;
  bool _isModelLoaded = false;
  String _statusMessage = 'Loading model...';

  String _getLocalizedText(String key) {
    final texts = {
      'loadingModel': {
        'English': 'Loading AI model...',
        'Hindi': 'एआई मॉडल लोड हो रहा है...',
        'Telugu': 'AI మోడల్ లోడ్ అవుతోంది...',
      },
      'modelLoadedSuccess': {
        'English': 'Model loaded successfully!',
        'Hindi': 'मॉडल सफलतापूर्वक लोड हो गया!',
        'Telugu': 'మోడల్ విజయవంతంగా లోడ్ చేయబడింది!',
      },
      'errorLoadingModel': {
        'English': 'Error loading model: ',
        'Hindi': 'मॉडल लोड करने में त्रुटि: ',
        'Telugu': 'మోడల్ లోడ్ చేయడంలో లోపం: ',
      },
      'waitModelLoad': {
        'English': 'Please wait for the model to load',
        'Hindi': 'कृपया मॉडल लोड होने की प्रतीक्षा करें',
        'Telugu': 'దయచేసి మోడల్ లోడ్ చేయడానికి నిరీక్షించండి',
      },
      'analyzingImage': {
        'English': 'Analyzing image...',
        'Hindi': 'छवि का विश्लेषण...',
        'Telugu': 'చిత్రాన్ని విశ్లేషిస్తోంది...',
      },
      'errorCapturing': {
        'English': 'Error capturing image: ',
        'Hindi': 'छवि कैप्चर करने में त्रुटि: ',
        'Telugu': 'చిత్రాన్ని క్యాప్చర్ చేయడంలో లోపం: ',
      },
      'errorSelecting': {
        'English': 'Error selecting image: ',
        'Hindi': 'छवि चुनने में त्रुटि: ',
        'Telugu': 'చిత్రాన్ని ఎంచుకోవడంలో లోపం: ',
      },
      'error': {'English': 'Error', 'Hindi': 'त्रुटि', 'Telugu': 'లోపం'},
      'ok': {'English': 'OK', 'Hindi': 'ठीक है', 'Telugu': 'సరే'},
      'captureImage': {
        'English': 'Capture Image',
        'Hindi': 'तस्वीर लें',
        'Telugu': 'చిత్రం తీయండి',
      },
      'camera': {'English': 'Camera', 'Hindi': 'कैमरा', 'Telugu': 'కెమెరా'},
      'gallery': {'English': 'Gallery', 'Hindi': 'गैलरी', 'Telugu': 'గ్యాలరీ'},
    };

    return texts[key]?[widget.language] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _statusMessage = _getLocalizedText('loadingModel');
    });

    try {
      await _classifier.loadModel();

      setState(() {
        _isModelLoaded = true;
        _isLoading = false;
        _statusMessage = _getLocalizedText('modelLoadedSuccess');
      });

      // Clear success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _statusMessage = '';
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isModelLoaded = false;
        _statusMessage = _getLocalizedText('errorLoadingModel') + e.toString();
      });
      print('Error loading model: $e');
    }
  }

  Future<void> _takePicture() async {
    // Check if model is loaded before proceeding
    if (!_isModelLoaded) {
      _showErrorDialog(_getLocalizedText('waitModelLoad'));
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
          _isLoading = true;
          _statusMessage = _getLocalizedText('analyzingImage');
        });

        // Classify the image
        final result = await _classifier.classifyImage(photo.path);

        setState(() {
          _isLoading = false;
          _statusMessage = '';
        });

        // ✅ CRITICAL FIX: Use push instead of pushReplacement and await result
        if (mounted) {
          final resultFromScreen = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                imagePath: photo.path,
                diseaseName: result['diseaseName'] as String,
                confidence: result['confidence'] as double,
                language: widget.language,
              ),
            ),
          );

          // ✅ If result returned (user pressed Home), pass it back to HomeScreen
          if (resultFromScreen != null && mounted) {
            print('=== CAMERA RECEIVED RESULT ===');
            print('Result: $resultFromScreen');
            Navigator.pop(context, resultFromScreen);
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '';
      });
      print('Error taking picture: $e');
      _showErrorDialog(_getLocalizedText('errorCapturing') + e.toString());
    }
  }

  Future<void> _pickFromGallery() async {
    // Check if model is loaded before proceeding
    if (!_isModelLoaded) {
      _showErrorDialog(_getLocalizedText('waitModelLoad'));
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
          _isLoading = true;
          _statusMessage = _getLocalizedText('analyzingImage');
        });

        // Classify the image
        final result = await _classifier.classifyImage(photo.path);

        setState(() {
          _isLoading = false;
          _statusMessage = '';
        });

        // ✅ CRITICAL FIX: Use push instead of pushReplacement and await result
        if (mounted) {
          final resultFromScreen = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                imagePath: photo.path,
                diseaseName: result['diseaseName'] as String,
                confidence: result['confidence'] as double,
                language: widget.language,
              ),
            ),
          );

          // ✅ If result returned (user pressed Home), pass it back to HomeScreen
          if (resultFromScreen != null && mounted) {
            print('=== CAMERA RECEIVED RESULT ===');
            print('Result: $resultFromScreen');
            Navigator.pop(context, resultFromScreen);
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '';
      });
      print('Error picking image: $e');
      _showErrorDialog(_getLocalizedText('errorSelecting') + e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedText('error')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedText('ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedText('captureImage')),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status message
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isModelLoaded ? Colors.green : Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Image preview
            if (_imageFile != null)
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 30),

            // Loading indicator or buttons
            if (_isLoading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(_statusMessage, style: const TextStyle(fontSize: 14)),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isModelLoaded ? _takePicture : null,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: Text(
                      _getLocalizedText('camera'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isModelLoaded
                          ? Colors.blue
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _isModelLoaded ? _pickFromGallery : null,
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: Text(
                      _getLocalizedText('gallery'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isModelLoaded
                          ? Colors.green
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }
}
