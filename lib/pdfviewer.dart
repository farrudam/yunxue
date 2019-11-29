import 'package:chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';

class PdfViewer extends StatefulWidget {

  String pdf;
  String sala;

  PdfViewer(this.pdf, this.sala);
  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {

  bool _isLoading = true;
  PDFDocument document;
 

 @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(widget.pdf);

    setState(() => _isLoading = false);
  }

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Yunxue",
          debugShowCheckedModeBanner: false,
          theme: Theme.of(context).platform == TargetPlatform.iOS
            ? kIOSTheme
            : kDefaultTheme,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Yunxue"),
          actions: <Widget>[
             IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                Navigator.of(context).push(
                    new MaterialPageRoute(builder: (BuildContext context) {
                  return ChatScreen(widget.sala);
                }));
              }
          ),
          ],
        ),
        body: Center(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : PDFViewer(document: document)),
      ),
    );
  }
}