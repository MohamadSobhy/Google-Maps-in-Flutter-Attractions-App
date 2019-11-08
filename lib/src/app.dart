import 'package:flutter/material.dart';

import './screens/home_screen.dart';

class GoogleMapsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
    );
  }
}
