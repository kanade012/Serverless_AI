import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../widget/drawing_canvas.dart';
import '../widget/prediction.dart';
import '../widget/recogniger.dart';

class tflite_flutter extends StatefulWidget {
  const tflite_flutter({Key? key}) : super(key: key);

  @override
  State<tflite_flutter> createState() => _tflite_flutterState();
}

class _tflite_flutterState extends State<tflite_flutter> {
  final _points = <Offset?>[];
  final _recognizer = Recognizer();
  var _prediction = <Prediction>[];

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tflite_flutter'),
      ),
      body: Column(
        children: <Widget>[
          _mnistPreviewImage(),
          const SizedBox(height: 10),
          Container(
            width: Constants.canvasSize + Constants.borderSize * 2,
            height: Constants.canvasSize + Constants.borderSize * 2,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: Constants.borderSize),
            ),
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                Offset _localPosition = details.localPosition;
                if (_localPosition.dx >= 0 &&
                    _localPosition.dx <= Constants.canvasSize &&
                    _localPosition.dy >= 0 &&
                    _localPosition.dy <= Constants.canvasSize) {
                  setState(() {
                    _points.add(_localPosition);
                  });
                }
              },
              onPanEnd: (DragEndDetails details) {
                _points.add(null);
                _recognize();
              },
              child: CustomPaint(painter: DrawingPainter(_points)),
            ),
          ),
          PredictionWidget(predictions: _prediction),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.clear),
        onPressed: () {
          setState(() {
            _points.clear();
            _prediction.clear();
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  Widget _mnistPreviewImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.black,
      child: FutureBuilder(
        future: _previewImage(),
        builder: (BuildContext _, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data! as Uint8List, fit: BoxFit.fill);
          } else {
            return const Center(child: Text('Error'));
          }
        },
      ),
    );
  }

  Future<Uint8List> _previewImage() async {
    return await _recognizer.previewImage(_points);
  }

  void _initModel() async {
    await _recognizer.loadModel();
  }

  void _recognize() async {
    List<Map<String, dynamic>> pred = await _recognizer.recognize(_points);
    setState(() {
      _prediction = pred.map((json) => Prediction.fromJson(json)).toList();
    });
  }
}
