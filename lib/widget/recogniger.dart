import 'dart:typed_data';
import 'dart:ui';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/material.dart';

import '../config/constants.dart';

final _canvasCullRect = Rect.fromPoints(
  Offset(0, 0),
  Offset(Constants.imageSize, Constants.imageSize),
);

final _whitePaint = Paint()
  ..strokeCap = StrokeCap.round
  ..color = Colors.white
  ..strokeWidth = Constants.strokeWidth;

final _bgPaint = Paint()
  ..color = Colors.black;

class Recognizer {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/tflite_flutter/mnist_model.tflite');
  }

  Future<List<Map<String, dynamic>>> recognize(List<Offset?> points) async {
    if (_interpreter == null) {
      throw Exception("Model not loaded. Ensure loadModel() is called before recognize().");
    }
    final picture = _pointsToPicture(points);
    Uint8List inputBytes = await _imageToByteListUint8(picture, Constants.mnistImageSize);
    var input = inputBytes.buffer.asUint8List();

    List<List<double>> output = List.generate(1, (i) => List.filled(10, 0.0));
    _interpreter.run(input, output);

    return _parseOutput(output);
  }

  List<Map<String, dynamic>> _parseOutput(List<List<double>> output) {
    List<Map<String, dynamic>> predictions = [];
    for (int i = 0; i < output[0].length; i++) {
      predictions.add({"index": i, "confidence": output[0][i]});
    }
    predictions.sort((a, b) => b['confidence'].compareTo(a['confidence']));
    return predictions;
  }

  Future<Uint8List> _imageToByteListUint8(Picture picture, int size) async {
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
    final buffer = Float32List(size * size);
    for (int i = 0, j = 0; i < byteData!.lengthInBytes; i += 4, j++) {
      buffer[j] = ((byteData.getUint8(i) + byteData.getUint8(i + 1) + byteData.getUint8(i + 2)) / 3) / 255.0;
    }
    return buffer.buffer.asUint8List();
  }

  Future<Uint8List> previewImage(List<Offset?> points) async {
    final picture = _pointsToPicture(points);
    final image = await picture.toImage(Constants.mnistImageSize, Constants.mnistImageSize);
    var pngBytes = await image.toByteData(format: ImageByteFormat.png);
    return pngBytes!.buffer.asUint8List();
  }

  Picture _pointsToPicture(List<Offset?> points) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _canvasCullRect)
      ..scale(Constants.mnistImageSize / Constants.canvasSize);

    canvas.drawRect(Rect.fromLTWH(0, 0, Constants.imageSize, Constants.imageSize), _bgPaint);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, _whitePaint);
      }
    }
    return recorder.endRecording();
  }

  void dispose() {
    _interpreter.close();
  }
}
