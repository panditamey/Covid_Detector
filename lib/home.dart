import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late File _image;
  var tf = 1;
  final imagepicker = ImagePicker();
  List? _predictions = [];

  @override
  void initState() {
    super.initState();
    loadmodel();
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  detect_image(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 4,
        threshold: 0.95,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _predictions = prediction;
      tf = 0;
      print(_predictions);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadimage_gallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print("NOT");
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image);
  }

  _loadimage_camera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'COVID DETECTOR',
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        height: h,
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 180,
              width: 180,
              padding: EdgeInsets.all(10),
              child: Image.asset('images/x-ray.png'),
            ),
            // Container(
            //   child: Text(
            //     'COVID DETECTOR',
            //     style: GoogleFonts.ubuntu(
            //         fontSize: 20, fontWeight: FontWeight.bold),
            //   ),
            // ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              height: 70,
              width: 300,
              child: RaisedButton(
                onPressed: () {
                  _loadimage_camera();
                },
                color: Colors.blue[200],
                child: Text(
                  "Camera",
                  style: GoogleFonts.ubuntu(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              height: 70,
              width: 300,
              child: RaisedButton(
                onPressed: () {
                  _loadimage_gallery();
                },
                color: Colors.blue[200],
                child: Text(
                  "Gallery",
                  style: GoogleFonts.ubuntu(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            tf == 0
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          height: 200,
                          width: 200,
                          child: Image.file(_image),
                        ),
                        Text(
                          "IT IS " +
                              _predictions![0]['label'].toString().substring(1),
                          style: GoogleFonts.ubuntu(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('Confidence : ' +
                            _predictions![0]['confidence'].toString())
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
