import 'package:easybiz/view/company_data.dart';
import 'package:flutter/material.dart';
import 'view/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    print(comp);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: user != null ? CompanyData() : Login());
  }
}
