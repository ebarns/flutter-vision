import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class DetailWidget extends StatefulWidget {
  File _file;

  DetailWidget(this._file);

  @override
  State<StatefulWidget> createState() {
    return _DetailState();
  }
}

class _DetailState extends State<DetailWidget> {
  final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
  List<Face> faceList = [];

  @override
  void initState() {
    super.initState();
    getFace();
  }

  Future getFace() async {
    print("getting faces");
    final File imageFile = widget._file;
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);
    final List<Face> faces = await faceDetector.detectInImage(visionImage);
    print(faces);

    this.setState(() {
      faceList = faces;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Face Recognition'),
        ),
        body: Column(
          children: <Widget>[
            buildImage(context),
          ],
        ));
  }

  Widget buildImage(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
          decoration: BoxDecoration(color: Colors.black),
          child: Center(
            child: widget._file == null
                ? Text('No Image')
                : FutureBuilder<Size>(
                    future: _getImageSize(
                        Image.file(widget._file, fit: BoxFit.fitWidth)),
                    builder:
                        (BuildContext context, AsyncSnapshot<Size> snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                            child:
                                Image.file(widget._file, fit: BoxFit.fitWidth));
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
          )),
    );
  }

  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(
        (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble())));
    return completer.future;
  }
}
