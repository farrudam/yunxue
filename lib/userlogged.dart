import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  GoogleSignIn _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  void showLoading() {
    Center(
      child: CircularProgressIndicator(),
    );
  }

  void _signOut() {
    _googleSignIn.signOut();
  }

  initLogin() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) async {
      if (account != null) {
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (BuildContext context) {
          return Home();
        }));
      } else {
        doLogin();
      }
    });
    _googleSignIn.signInSilently().whenComplete(() {
      Navigator.of(context)
          .push(new MaterialPageRoute(builder: (BuildContext context) {
        return Home();
      }));
    });
  }

  doLogin() async {
    showLoading();
    await _googleSignIn.signIn();
    initLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: 
        Center(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
          Text("Bem vindo, ao sistema. \n\nFaça o login para acessar as funcionalidades.",
          textAlign: TextAlign.center,),
          Padding(
            padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 20.0),
          child:
            RaisedButton(
              padding: EdgeInsets.all(10.0),
          onPressed: () => doLogin(),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Image.asset(
              'assets/google_logo.png',
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.3),
              Text("Entrar com o Google"),
            ],
          ) 
      )),
    ]),
        ));
  }
}
