import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EmojiClassifier(),
    );
  }
}

class EmojiClassifier extends StatefulWidget {
  @override
  _EmojiClassifierState createState() => _EmojiClassifierState();
}

class _EmojiClassifierState extends State<EmojiClassifier> {
  File _imageFile;
  List _identifiedResult;
  @override
  void initState() {
    super.initState();
    loadEmojiModel();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future selectImage() async {
    final picker = ImagePicker();
    var image = await picker.getImage(source: ImageSource.gallery, maxHeight: 300);
    identifyImage(image);
  }

  Future loadEmojiModel() async {
    Tflite.close();
    String result;
    result = await Tflite.loadModel(
      model: "assets/emoji_model_unquant.tflite",
      labels: "assets/emoji_labels.txt",
    );
    print(result);
  }

  Future identifyImage(image) async {
    _identifiedResult = null;
    // Run tensorflowlite image classification model on the image
    print("classification start $image");
    final List result = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0, 
      imageStd: 255.0, 
      numResults: 2, 
      threshold: 0.2, 
      asynch: true
    );
    print("classification done");
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
        _identifiedResult = result;
      } else {
        print('No image selected.');
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Emoji Classifier",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white70,
        child: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(2, 2),
                      spreadRadius: 2,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: (_imageFile != null)?
                Image.file(_imageFile) :
                Image.network('https://i.imgur.com/sUFH1Aq.png')
              ),
              FloatingActionButton(
                tooltip: 'Select Image',
                onPressed: (){
                  selectImage();
                },
                child: Icon(Icons.add_a_photo,
                size: 25,
                color: Colors.blue,
                ),
                backgroundColor: Colors.white,
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                child: Column(
                  children: _identifiedResult != null ? [
                    Text(
                      "Result : ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                    Card(
                        elevation: 1.0,
                        color: Colors.white,
                        child: Container(
                          width: 100,
                          margin: EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "${_identifiedResult[0]["label"]}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      )
                    ]
                  :[]
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

