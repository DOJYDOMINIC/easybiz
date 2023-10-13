import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const.dart';


class TextFieldOne extends StatelessWidget {
  const TextFieldOne(
      {super.key, required this.hinttext, required this.controller, required this.onchange, required this.obsecuretxt, this.preicon, this.keytype, this.fillcolor, this.sufix});

  final String hinttext;
  final TextEditingController controller;
  final ValueChanged onchange;
  final bool obsecuretxt;
  final IconData? preicon;
  final IconData? sufix;
  final TextInputType? keytype;
  final Color? fillcolor;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        keyboardType: keytype,
        decoration: InputDecoration(suffixIcon:Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
          child: Icon(sufix,color: Colors.grey,size: 30,),
        ) ,errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 2,
                  color:  Color.fromARGB(255, 31, 65, 188).withOpacity(.5)), // Border color when not in focus
            ),
            hintText: hinttext,
            labelStyle: GoogleFonts.poppins(color: Colors.black.withOpacity(.8)),
            fillColor: fillcolor == null ? app_color.withOpacity(.05) : fillcolor,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 2,
                  color:app_color), // Border color when focused
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white)),

        ),
        style: TextStyle(color: Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required.';
          }
          return null;
        },
        cursorColor: app_color,
        obscureText: obsecuretxt,
        obscuringCharacter: '*',
        controller: controller,
        onChanged: onchange,
      ),
    );
  }
}

