import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class Pytorch_lite extends StatefulWidget {
  const Pytorch_lite({Key? key}) : super(key: key);

  @override
  _Pytorch_liteState createState() => _Pytorch_liteState();
}

class _Pytorch_liteState extends State<Pytorch_lite> {
  ClassificationModel? _imageModel;
  late ModelObjectDetection _objectModelYoloV8;

  String? textToShow;
  List? _prediction;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  //load your model
  Future loadModel() async {
    String pathImageModel = "assets/pytorch_lite/model_classification.pt";
    String pathObjectDetectionModelYolov8 = "assets/pytorch_lite/yolov8s.torchscript";
    try {
      _imageModel = await PytorchLite.loadClassificationModel(
          pathImageModel, 224, 224, 1000,
          labelPath: "assets/pytorch_lite/label_classification_imageNet.txt");
      _objectModelYoloV8 = await PytorchLite.loadObjectDetectionModel(
          pathObjectDetectionModelYolov8, 80, 640, 640,
          labelPath: "assets/pytorch_lite/labels_objectDetection_Coco.txt",
          objectDetectionModelType: ObjectDetectionModelType.yolov8);
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  Future runObjectDetectionYoloV8() async {
    //pick a random image

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    Stopwatch stopwatch = Stopwatch()..start();

    objDetect = await _objectModelYoloV8.getImagePrediction(
        await File(image!.path).readAsBytes(),
        minimumScore: 0.1,
        iOUThreshold: 0.3);
    textToShow = inferenceTimeAsString(stopwatch);

    print('object executed in ${stopwatch.elapsed.inMilliseconds} ms');
    for (var element in objDetect) {
      print({
        "score": element?.score,
        "className": element?.className,
        "class": element?.classIndex,
        "rect": {
          "left": element?.rect.left,
          "top": element?.rect.top,
          "width": element?.rect.width,
          "height": element?.rect.height,
          "right": element?.rect.right,
          "bottom": element?.rect.bottom,
        },
      });
    }

    setState(() {
      _image = File(image.path);
    });
  }

  String inferenceTimeAsString(Stopwatch stopwatch) =>
      "Inference Took ${stopwatch.elapsed.inMilliseconds} ms";

  Future runClassification() async {
    objDetect = [];
    //pick a random image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    //get prediction
    //labels are 1000 random english words for show purposes
    print(image!.path);
    Stopwatch stopwatch = Stopwatch()..start();

    textToShow = await _imageModel!
        .getImagePrediction(await File(image.path).readAsBytes());
    textToShow = "${textToShow ?? ""}, ${inferenceTimeAsString(stopwatch)}";

    List<double?>? predictionList = await _imageModel!.getImagePredictionList(
      await File(image.path).readAsBytes(),
    );

    print(predictionList);
    setState(() {
      _image = File(image.path);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pytorch_lite'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: objDetect.isNotEmpty
                  ? _image == null
                  ? Center(child: const Text('No image selected.'))
                  : _objectModelYoloV8.renderBoxesOnImage(_image!, objDetect)
                  : _image == null
                  ? Center(child: const Text('No image selected.'))
                  : Image.file(_image!),
            ),
            Center(
              child: Visibility(
                visible: textToShow != null,
                child: Text(
                  "$textToShow",
                  maxLines: 3,
                ),
              ),
            ),
            TextButton(
              onPressed: runClassification,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                "Run Classification",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: runObjectDetectionYoloV8,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                "Run object detection YoloV8 with labels",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Visibility(
                visible: _prediction != null,
                child: Text(_prediction != null ? "${_prediction![0]}" : ""),
              ),
            )
          ],
        ),
      );
  }
}