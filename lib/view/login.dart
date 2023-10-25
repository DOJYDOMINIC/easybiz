import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';
import '../widget/main_fields.dart';
import 'company_data.dart';

String? user;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

bool isPressed = false;
String username = '';
String password = '';
String compcode = '';

class _LoginState extends State<Login> {
  Future<void> loginApi(
    String username,
    String password,
  ) async {
    var usercodeset;

    try {
      final uri = Uri.parse('${api}/login');
      final requestBody = {
        'username': username,
        'password': password,
        // 'compcode': compcode,
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', username);
        user = prefs.getString('user');
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        final Map<String, dynamic> data = json.decode(response.body);
        usercodeset = data['result'][0]['user_id'];
        compcode = data['result'][0]['comp_code'];
        prefs.setString('usercode', usercodeset);
        prefs.setString('comp', compcode);

        print(data.toString());
        // Now, you can navigate to the CompanyData page

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CompanyData()),
        );
        // print(usercodeset.runtimeType.toString());
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text('login Failed'),
              actions: <Widget>[
                TextButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        // print('Error: ${response.statusCode}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Text('Something went Wrong'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      // print('Error: $e');
    }
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();

  // TextEditingController _compcode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!FocusScope.of(context).hasPrimaryFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .4,
                    width: MediaQuery.of(context).size.width * .7,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 31, 65, 188).withOpacity(.03),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(300),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'E',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 60,
                                    color: app_color,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'z',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 40,
                                      color: app_color,
                                    ),
                                  ),
                                ),
                                Text(
                                  'B',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 60,
                                    color: orng,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'iz',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 40,
                                      color: orng,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Makes Your Trade Easy',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          TextFieldOne(
                            hinttext: 'Username',
                            controller: _username,
                            obsecuretxt: false,
                            onchange: (value) {
                              username = value;
                            },
                          ),
                          TextFieldOne(
                            hinttext: 'Password',
                            controller: _password,
                            obsecuretxt: true,
                            onchange: (value) {
                              password = value;
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_formKey.currentState!.validate()) {
                                isPressed = !isPressed;
                                loginApi(username, password);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: isPressed
                                  ? LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [app_color, app_color],
                                    )
                                  : LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [orng, orng],
                                    ),
                              boxShadow: isPressed
                                  ? [
                                      BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(2, 2),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.transparent,
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
