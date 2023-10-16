import 'package:easybiz/view/company_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  user = prefs.getString('user')?? '';
  comp = prefs.getString('comp')?? '';

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // print(comp);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: comp.isNotEmpty  ? CompanyData() : Login());
  }
}