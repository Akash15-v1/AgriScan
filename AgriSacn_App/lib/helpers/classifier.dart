import 'dart:io';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:flutter/services.dart';

class Classifier {
  late List<String> _labels;

  Future<void> loadModel() async {
    try {
      if (!(Platform.isAndroid || Platform.isIOS)) {
        throw MissingPluginException('Platform not supported');
      }

      String? res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 4,
      );
      print('Model loaded successfully: $res');

      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .where((label) => label.isNotEmpty)
          .toList();
      print('Labels loaded: ${_labels.length}');
    } catch (e) {
      print('Error loading model: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    try {
      if (!(Platform.isAndroid || Platform.isIOS)) {
        throw MissingPluginException('Platform not supported');
      }

      final stopwatch = Stopwatch()..start();

      // CRITICAL: Since your model has built-in preprocessing,
      // use imageMean=0.0 and imageStd=1.0 to pass raw [0-255] values
      var recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        imageMean: 0.0, // no normalization in app
        imageStd: 1.0, // pass raw 0–255
        numResults: _labels.length,
        threshold: 0.05,
        asynch: true,
      );

      stopwatch.stop();

      print('\nAll predictions:');
      print(recognitions);
      if (recognitions != null && recognitions.isNotEmpty) {
        recognitions.sort(
          (a, b) =>
              (b['confidence'] as double).compareTo(a['confidence'] as double),
        );

        for (final pred in recognitions) {
          print(
            '${pred['label']}: ${(pred['confidence'] * 100).toStringAsFixed(2)}%',
          );
        }

        var topResult = recognitions[0];
        print('\nTop prediction: ${topResult['label']}');
        print(
          'Confidence: ${(topResult['confidence'] * 100).toStringAsFixed(2)}%',
        );
        print('Time: ${stopwatch.elapsedMilliseconds}ms');

        return {
          'diseaseName': topResult['label'],
          'confidence': topResult['confidence'],
          'allPredictions': recognitions,
        };
      }

      return {'diseaseName': 'No prediction', 'confidence': 0.0};
    } catch (e) {
      print('Error: $e');
      return {'diseaseName': 'Error', 'confidence': 0.0, 'error': e.toString()};
    }
  }

  void dispose() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Tflite.close();
    }
  }
}
