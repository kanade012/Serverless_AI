// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pytorch_mobile/pytorch_mobile.dart';
// import 'package:pytorch_mobile/model.dart';
// import 'dart:io';
//
// class pytorch_mobile extends StatefulWidget {
//   @override
//   _pytorch_mobileState createState() => _pytorch_mobileState();
// }
//
// class _pytorch_mobileState extends State<pytorch_mobile> {
//   final ImagePicker _picker = ImagePicker();
//   late Model model;
//   File? file;
//   String? _pred;
//
//   @override
//   void initState() {
//     super.initState();
//     loadmodel().then((value) {
//       print('load model');
//       setState(() {});
//     });
//   }
//
//   Future loadmodel() async {
//     Model imagemodel = await PyTorchMobile.loadModel('assets/resnet.pt');
//     setState(() {
//       model = imagemodel;
//     });
//   }
//
//   Future predict() async {
//     String prediction = await model.getImagePrediction(file!, 224, 224, "assets/labels.csv");
//     setState(() {
//       _pred = prediction;
//     });
//   }
//
//   Future loadImage() async {
//     final image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         file = File(image.path);
//         predict();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("pytorch_mobile"),
//       ),
//       body: Column(
//         children: [
//           Container(
//             height: 500,
//             child: file == null
//                 ? const Center(child: Text('no Image'))
//                 : Image.file(file!, fit: BoxFit.fitWidth),
//           ),
//           SizedBox(
//             child: TextButton(
//               onPressed: () {
//                 loadImage();
//               },
//               child: const Text('pick image for predict'),
//             ),
//           ),
//           _pred == null ? const Text('') : Text(_pred!)
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class RunModelByImageDemo extends StatefulWidget {
  const RunModelByImageDemo({Key? key}) : super(key: key);

  @override
  _RunModelByImageDemoState createState() => _RunModelByImageDemoState();
}

class _RunModelByImageDemoState extends State<RunModelByImageDemo> {
  ClassificationModel? _imageModel;
  late ModelObjectDetection _objectModel;
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
    String pathObjectDetectionModel = "assets/pytorch_lite/yolov5s.torchscript";
    String pathObjectDetectionModelYolov8 = "assets/pytorch_lite/yolov8s.torchscript";
    try {
      _imageModel = await PytorchLite.loadClassificationModel(
          pathImageModel, 224, 224, 1000,
          labelPath: "assets/pytorch_lite/label_classification_imageNet.txt");
      _objectModel = await PytorchLite.loadObjectDetectionModel(
          pathObjectDetectionModel, 80, 640, 640,
          labelPath: "assets/pytorch_lite/labels_objectDetection_Coco.txt");
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

  //run an image model
  Future runObjectDetectionWithoutLabels() async {
    //pick a random image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    Stopwatch stopwatch = Stopwatch()..start();

    objDetect = await _objectModel
        .getImagePredictionList(await File(image!.path).readAsBytes());
    textToShow = inferenceTimeAsString(stopwatch);

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
      //this.objDetect = objDetect;
      _image = File(image.path);
    });
  }

  Future runObjectDetection() async {
    //pick a random image

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    Stopwatch stopwatch = Stopwatch()..start();
    objDetect = await _objectModel.getImagePrediction(
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
      //this.objDetect = objDetect;
      _image = File(image.path);
    });
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
      //this.objDetect = objDetect;
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
      //this.objDetect = objDetect;
      _image = File(image.path);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Run model with Image'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: objDetect.isNotEmpty
                  ? _image == null
                  ? const Text('No image selected.')
                  : _objectModel.renderBoxesOnImage(_image!, objDetect)
                  : _image == null
                  ? const Text('No image selected.')
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
              onPressed: runObjectDetection,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                "Run object detection with labels",
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
            TextButton(
              onPressed: runObjectDetectionWithoutLabels,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                "Run object detection without labels",
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