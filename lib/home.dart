import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final auth = FirebaseAuth.instance;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController salaController = TextEditingController();

  Future<Null> _ensureLoggedIn({String type}) async {
    
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) user = await googleSignIn.signInSilently();
    if (user == null) user = await googleSignIn.signIn();
      if (await auth.currentUser() == null) {
        GoogleSignInAuthentication credentials =
          await googleSignIn.currentUser.authentication;
        await auth.signInWithCredential(GoogleAuthProvider.getCredential(
          idToken: credentials.idToken, accessToken: credentials.accessToken));
      }
      if (user != null && type == "new" ) {
      DocumentReference addedDocRef = await Firestore.instance.collection("messages").add({
      "chat": googleSignIn.currentUser.id.toString() + DateTime.now().millisecondsSinceEpoch.toString(),});
      String sala = addedDocRef.documentID;
      print (sala);
        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) {
          return ChatScreen(sala);
        }));
      }

      if(user != null && type == "existing"){
        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) {
          return ChatScreen(salaController.text);
        }));
      }
    }
  
  @override
  Widget build(BuildContext context) {
    final salaField = TextField(
      controller: salaController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Sala",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final google = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
              _ensureLoggedIn(type: "new");
            },
            child: Row(
              children: <Widget>[
                Image.asset('assets/google_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.15),
                Text("Entrar com Google",
                    textAlign: TextAlign.center,
                    style: style.copyWith(
                        color: Colors.purple, fontWeight: FontWeight.bold)),
              ],
            )));

    final entrarSala = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          _ensureLoggedIn(type: "existing");
        },
        child: Text("Entrar",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.purple, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text("Yunxue"),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Center(
                child: Container(
                    child: Padding(
                        padding: const EdgeInsets.all(36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "Bem vindo ao Yunxue.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32.0),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Container(
                              child: Text(
                                  "Para criar uma nova sala faça o login."),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            google,
                            SizedBox(height: 25.0),
                            Container(
                              child: Text("Entrar em uma sala disponível:"),
                            ),
                            SizedBox(height: 25.0),
                            salaField,
                            SizedBox(
                              height: 25.0,
                            ),
                            entrarSala,
                          ],
                        ))))));
  }
}
