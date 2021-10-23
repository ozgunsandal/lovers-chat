import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/landing_page.dart';
import 'package:flutter_lovers/locator.dart';
import 'package:flutter_lovers/view_model/view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ViewModel(),
      child: MaterialApp(
        title: 'Flutter Lovers',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.purple),
        home: LandingPage(),
      ),
    );
  }
}
