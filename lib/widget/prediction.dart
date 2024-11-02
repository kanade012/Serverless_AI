import 'package:flutter/material.dart';

class PredictionWidget extends StatelessWidget {
  final List<Prediction> predictions;
  const PredictionWidget({Key? key, required this.predictions}) : super(key: key);

  Widget _numberWidget(int num, Prediction? prediction) {
    return Column(
      children: <Widget>[
        Text(
          '$num',
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: prediction == null
                ? Colors.black
                : Colors.red.withOpacity(
              (prediction.confidence! * 2).clamp(0, 1).toDouble(),
            ),
          ),
        ),
        Text(
          '${prediction?.confidence?.toStringAsFixed(3) ?? ''}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var styles = List<Prediction?>.filled(10, null);
    for (var prediction in predictions) {
      if (prediction.index != null) {
        styles[prediction.index!] = prediction;
      }
    }

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[for (var i = 0; i < 5; i++) _numberWidget(i, styles[i])],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[for (var i = 5; i < 10; i++) _numberWidget(i, styles[i])],
        ),
      ],
    );
  }
}
class Prediction {
  final double? confidence;
  final int? index;
  final String? label;

  Prediction({this.confidence, this.index, this.label});

  factory Prediction.fromJson(Map<dynamic, dynamic> json) {
    return Prediction(
      confidence: json['confidence'],
      index: json['index'],
      label: json['label'],
    );
  }
}
