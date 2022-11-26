import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:partiture_prototype/entity/partitur.dart';
import 'package:partiture_prototype/pages/Modal.dart';
import 'package:partiture_prototype/pages/loader.dart';
import 'package:partiture_prototype/pages/login_page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

enum Options { account, settings, logout }

class _ProfilePageState extends State<ProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;
  var _popupMenuItemIndex = 0;

  late User _currentUser;

  late List<Modal> itemList;
  final mainReference = FirebaseDatabase.instance.ref();
  final db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _titleTextController = TextEditingController();
  final _composerTextController = TextEditingController();
  final _commentTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    return Scaffold(
      appBar: AppBar(
        title: Text("Library"),
        centerTitle: true,
        leading: PopupMenuButton(
          onSelected: (value) {
            _onMenuItemSelected(value as int);
          },
          itemBuilder: (ctx) => [
            _buildPopupMenuItem(
                ' Account', Icons.account_circle, Options.account.index),
            _buildPopupMenuItem(
                ' Settings', Icons.settings, Options.settings.index),
            _buildPopupMenuItem(' Log Out', Icons.logout, Options.logout.index),
          ],
          child: Icon(
            Icons.menu,
          ),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  _titleTextController.clear();
                  _composerTextController.clear();
                  _commentTextController.clear();
                  showModalBottomSheet<void>(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0))),
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text('Add New Music Sheet'),
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: <Widget>[
                                        TextFormField(
                                          controller: _titleTextController,
                                          autofocus: true,
                                          decoration: InputDecoration(
                                            hintText: "Title",
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        TextFormField(
                                          controller: _composerTextController,
                                          decoration: InputDecoration(
                                            hintText: "Composer",
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        TextFormField(
                                          controller: _commentTextController,
                                          decoration: InputDecoration(
                                            hintText: "Comment",
                                          ),
                                        ),
                                        SizedBox(height: 24.0),
                                        OutlinedButton(
                                            child: Text(
                                              'Submit and Pick PDF',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              addPartitur(
                                                  _titleTextController.text,
                                                  _composerTextController.text,
                                                  _commentTextController.text);
                                            })
                                      ],
                                    ),
                                  ))
                            ],
                          ));
                    },
                  );
                },
                child: Icon(
                  Icons.add,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: StreamBuilder<List<Partitur>>(
          stream: partiturStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: Text("No data found, add new using + button"));
            } else if (snapshot.hasError) {
              return Center(child: Text("An Error has Occured"));
            } else {
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    Partitur currentModel = snapshot.data![index];
                    return Card(
                        child: ListTile(
                            title: Text(currentModel.title),
                            subtitle: Text(currentModel.composer),
                            onTap: () => showAlertDialog(context, currentModel),
                            trailing: GestureDetector(
                              onTap: () {
                                _titleTextController.text = currentModel.title;
                                _composerTextController.text =
                                    currentModel.composer;
                                _commentTextController.text =
                                    currentModel.comment;
                                showModalBottomSheet<void>(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25.0))),
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 18),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const Text('Edit Music Sheet'),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom),
                                                child: Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    children: <Widget>[
                                                      TextFormField(
                                                        controller:
                                                            _titleTextController,
                                                        autofocus: true,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: "Title",
                                                        ),
                                                      ),
                                                      SizedBox(height: 8.0),
                                                      TextFormField(
                                                        controller:
                                                            _composerTextController,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: "Composer",
                                                        ),
                                                      ),
                                                      SizedBox(height: 8.0),
                                                      TextFormField(
                                                        controller:
                                                            _commentTextController,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: "Comment",
                                                        ),
                                                      ),
                                                      SizedBox(height: 24.0),
                                                      OutlinedButton(
                                                          child: Text(
                                                            'Confirm',
                                                            style: TextStyle(
                                                              fontSize: 14.0,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            updatePartitur(
                                                                _titleTextController
                                                                    .text,
                                                                _composerTextController
                                                                    .text,
                                                                _commentTextController
                                                                    .text,
                                                                currentModel
                                                                    .pdf,
                                                                currentModel
                                                                    .id);
                                                          })
                                                    ],
                                                  ),
                                                ))
                                          ],
                                        ));
                                  },
                                );
                              },
                              child: Icon(
                                Icons.edit,
                              ),
                            )));
                  });
            }
          }),
    );
  }

  PopupMenuItem _buildPopupMenuItem(
      String title, IconData iconData, int option) {
    return PopupMenuItem(
      value: option,
      child: Row(
        children: [
          Icon(
            iconData,
            color: Colors.white,
          ),
          Text(title),
        ],
      ),
    );
  }

  _onMenuItemSelected(int value) async {
    setState(() {
      _popupMenuItemIndex = value;
    });

    if (value == Options.account.index) {
    } else if (value == Options.settings.index) {
    } else if (value == Options.logout.index) {
      setState(() {
        _isSigningOut = true;
      });
      await FirebaseAuth.instance.signOut();
      setState(() {
        _isSigningOut = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  Future<void> updatePartitur(
      String title, String comp, String comment, String pdf, String id) async {
    Partitur model =
        Partitur(title: title, composer: comp, comment: comment, pdf: pdf);
    await FirebaseFirestore.instance
        .collection(_currentUser.uid)
        .doc(id)
        .update(model.toMap());
  }

  Future<void> addPartitur(String title, String comp, String comment) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, withData: true, allowedExtensions: ['pdf']);

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = result.files.first.name;
      String id = _currentUser.uid;

      if (fileBytes != null) {
        await FirebaseStorage.instance
            .ref()
            .child('pdf/$id/$fileName')
            .putData(fileBytes);

        FirebaseFirestore.instance.collection(id).add({
          "title": title,
          "composer": comp,
          "comment": comment,
          "pdf": 'pdf/$id/$fileName'
        });
      }
    }
  }

  Stream<List<Partitur>> partiturStream() {
    try {
      return db.collection(_currentUser.uid).snapshots().map((notes) {
        final List<Partitur> notesFromFirestore = <Partitur>[];
        for (final DocumentSnapshot<Map<String, dynamic>> doc in notes.docs) {
          notesFromFirestore.add(Partitur.fromDocumentSnapshot(doc: doc));
        }
        return notesFromFirestore;
      });
    } catch (e) {
      rethrow;
    }
  }

  showAlertDialog(BuildContext context, Partitur model) {
    Widget deleteButton = TextButton(
      child: Text("Delete"),
      onPressed: () {
        _showToast(context, model);
        Navigator.pop(context);
      },
    );
    Widget openButton = TextButton(
      child: Text("Open"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoadURL(partitur: model),
          ),
        );
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(model.title),
      content: Text(model.comment),
      actions: [
        deleteButton,
        openButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showToast(BuildContext context, Partitur model) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(model.title + " will be removed"),
        action: SnackBarAction(
            label: 'Delete',
            onPressed: () {
              deletePartitur(model);
              deletePartiturData(model);
            }),
      ),
    );
  }

  Future<void> deletePartitur(model) async {
    await firebase_storage.FirebaseStorage.instance.ref(model.pdf).delete();
  }

  Future<void> deletePartiturData(model) async {
    await db.collection(_currentUser.uid).doc(model.id).delete();
  }
}
