import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:partiture_prototype/entity/partitur.dart';
import 'package:flutter/services.dart';

class LoadURL extends StatefulWidget {
  final Partitur partitur;

  const LoadURL({required this.partitur});

  @override
  _LoadURLState createState() => _LoadURLState();
}

class _LoadURLState extends State<LoadURL> {
  bool _isLoading = true;
  late String path;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  @override
  void initState() {
    super.initState();
    path = widget.partitur.pdf;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    return OrientationBuilder( 
      builder:(context, orientation){
      return Center(
        child: FutureBuilder(
            future: downloadURL(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String url = snapshot.data.toString();
                return _rebuild(url);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
        }  );
  }

  Future<String> downloadURL() async {
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(path)
        .getDownloadURL();
    return downloadURL;
  }

  Widget _rebuild(String url) {
      return PDF(
        swipeHorizontal: false,
                ).cachedFromUrl(url);
  }

}
