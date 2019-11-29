import 'dart:io';

import 'package:chat/home.dart';
import 'package:chat/pdfviewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';

class ChatScreen extends StatefulWidget {
  String sala;
  ChatScreen(this.sala);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final auth = FirebaseAuth.instance;

void _sendMessage({String text, String imgUrl, String sala, String pdfUrl}) {
  Firestore.instance
      .collection("messages")
      .document(sala)
      .collection("chat")
      .add({
    "text": text,
    "imgUrl": imgUrl,
    "pdfUrl": pdfUrl,
    "senderName": googleSignIn.currentUser.displayName,
    "senderPhotoUrl": googleSignIn.currentUser.photoUrl,
  });
}

final googleSignIn = GoogleSignIn();
_handleSubmitted(String text, String sala) async {
  await _ensureLoggedIn();
  _sendMessage(text: text, sala: sala);
}

Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) user = await googleSignIn.signInSilently();
  if (user == null) user = await googleSignIn.signIn();
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: credentials.idToken, accessToken: credentials.accessToken));
  }
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    String text = widget.sala;
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sala"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: text.isEmpty
                  ? null
                  : () {
                      final RenderBox box = context.findRenderObject();
                      Share.share(text,
                          subject: 'Esse é código de acesso a sala no Yunxue!',
                          sharePositionOrigin:
                              box.localToGlobal(Offset.zero) & box.size);
                    },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await googleSignIn.signOut();
                Navigator.of(context).push(
                    new MaterialPageRoute(builder: (BuildContext context) {
                  return Home();
                }));
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection("messages")
                    .document(widget.sala)
                    .collection("chat")
                    .snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      return ListView.builder(
                        reverse: false,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          List r = snapshot.data.documents.reversed.toList();
                          return ChatMessage(r[index].data, widget.sala);
                        },
                      );
                  }
                },
              ),
            ),
            Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: TextComposer(widget.sala),
            )
          ],
        ),
      ),
    );
  }
}

class TextComposer extends StatefulWidget {
  String sala;
  TextComposer(this.sala);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;
  final _textController = TextEditingController();

  void _reset() {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  FileType _pickingType;
  @override
  Widget build(BuildContext context) {
    void _settingModalBottomSheet(context) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                    leading: new Icon(Icons.insert_drive_file),
                    title: new Text('Documentos'),
                    onTap: () async {
                      await _ensureLoggedIn();
                      File pdfFile = await FilePicker.getFile(
                          type: FileType.ANY, fileExtension: "pdf");
                      if (pdfFile == null) return;
                      StorageUploadTask task = FirebaseStorage.instance
                          .ref()
                          .child(googleSignIn.currentUser.id.toString() +
                              DateTime.now().millisecondsSinceEpoch.toString())
                          .putFile(pdfFile);
                      StorageTaskSnapshot taskSnapshot = await task.onComplete;
                      String url = await taskSnapshot.ref.getDownloadURL();
                      _sendMessage(pdfUrl: url, sala: widget.sala);
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.image),
                    title: new Text('Galeria'),
                    onTap: () async {
                      await _ensureLoggedIn();
                      File imgFile = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (imgFile == null) return;
                      StorageUploadTask task = FirebaseStorage.instance
                          .ref()
                          .child(googleSignIn.currentUser.id.toString() +
                              DateTime.now().millisecondsSinceEpoch.toString())
                          .putFile(imgFile);
                      StorageTaskSnapshot taskSnapshot = await task.onComplete;
                      String url = await taskSnapshot.ref.getDownloadURL();
                      _sendMessage(imgUrl: url, sala: widget.sala);
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () async {
                      await _ensureLoggedIn();
                      File imgFile =
                          // await FilePicker.getFile(type: FileType.ANY, fileExtension: "pdf");
                          await ImagePicker.pickImage(
                              source: ImageSource.camera);
                      if (imgFile == null) return;
                      StorageUploadTask task = FirebaseStorage.instance
                          .ref()
                          .child(googleSignIn.currentUser.id.toString() +
                              DateTime.now().millisecondsSinceEpoch.toString())
                          .putFile(imgFile);
                      StorageTaskSnapshot taskSnapshot = await task.onComplete;
                      String url = await taskSnapshot.ref.getDownloadURL();
                      _sendMessage(imgUrl: url, sala: widget.sala);
                    },
                  ),
                ],
              ),
            );
          });
    }

    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(Icons.attachment),
                  onPressed: () {
                    _settingModalBottomSheet(context);
                  }),
            ),
            Expanded(
              child: TextFormField(
                controller: _textController,
                decoration:
                    InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onFieldSubmitted: (text) {
                  _handleSubmitted(text, widget.sala);
                  _reset();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _isComposing
                    ? () {
                        _handleSubmitted(_textController.text, widget.sala);
                        _reset();
                      }
                    : null,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;
  String sala;
  ChatMessage(this.data, this.sala);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data["senderName"],
                  style: Theme.of(context).textTheme.subhead,
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: data["imgUrl"] != null
                      ? Image.network(
                          data["imgUrl"],
                          width: 250.0,
                        )
                      : data["pdfUrl"] != null
                          ? Card(
                              child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                    leading: Icon(Icons.picture_as_pdf),
                                    title: Text('Tap to view.'),
                                    subtitle: Text(''),
                                    onTap: () async {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return PdfViewer(data["pdfUrl"], sala);
                                      }));

                                     /* PDFDocument doc =
                                          await PDFDocument.fromURL(
                                              data["pdfUrl"]);
                                      print(data["pdfUrl"]);
                                      PDFViewer(document: doc);*/
                                    }),
                              ],
                            ))
                          : Text(data["text"]),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
