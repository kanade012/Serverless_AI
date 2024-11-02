import 'package:flutter/material.dart';
import 'package:serverless_ai/page/pytorch_mobile.dart';
import 'package:serverless_ai/page/tflite_flutter.dart';

late Size ratio;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainPage(),
  ));
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    ratio = Size(MediaQuery.sizeOf(context).width / 412,
        MediaQuery.sizeOf(context).height / 892);
    return Scaffold(
      appBar: AppBar(
        title: Text("서버 없이 인공지능 모델 활용하기"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RunModelByImageDemo())),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: ratio.width * 300,
                height: ratio.height * 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text("Pytorch"),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DrawScreen())),              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: ratio.width * 300,
                height: ratio.height * 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text("Tensorflow Lite"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
