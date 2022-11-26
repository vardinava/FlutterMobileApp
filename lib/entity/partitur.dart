import 'package:cloud_firestore/cloud_firestore.dart';

class Partitur{
  String title;
  String composer;
  String comment;
  String pdf;
  String id;

  Partitur({
    required this.title,
    required this.composer,
    required this.comment,
    required this.pdf,
    String this.id="",
  });

  factory Partitur.fromDocumentSnapshot({required DocumentSnapshot<Map<String,dynamic>> doc}){
    return Partitur(
        title: doc.data()!["title"],
        composer: doc.data()!["composer"],
        comment:doc.data()!["comment"],
        pdf:doc.data()!["pdf"],
        id:doc.id
    );
}

  Map<String, dynamic> toMap() {
    return{
      "title":title,
      "composer":composer,
      "comment":comment,
      "pdf":pdf,
      "id":id
    };
  }
}