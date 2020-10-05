import 'package:flutter/material.dart';
import 'package:pharmadrone/map_screen.dart';
import 'package:pharmadrone/screen/pharmacie_add.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MapScreen(),
        'pharmacy-add': (context) => PharmacyScreen()
      },
    );
  }
}
