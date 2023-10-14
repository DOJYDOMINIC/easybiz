import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';
import 'itemspage.dart';
import 'login.dart';


String? selectedName;
String? username;


class CompanyData extends StatefulWidget {
  const CompanyData({super.key});

  @override
  State<CompanyData> createState() => _CompanyDataState();
}

class _CompanyDataState extends State<CompanyData> {


  List finalData = [];
  List SelectedData = [];

  @override
  void initState() {
    super.initState();
    Loginin();
    CustLocation();
    // '${prefs.getString('location')}'
  }

  Future<void> CustLocation() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('location') != null){
      locationcontroller.text = prefs.getString('location')!;
      SelectedArea(locationcontroller.text);

    }else{
      locationcontroller.text;
    }
  }

  Future<void> Loginin() async {
    try {
      final uri = Uri.parse('$api/area');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final requestBody = {
        'compcode': '${prefs.getString('comp')}',
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          if(data['data']!=[]){
            finalData = data['data'];
          }
          print(finalData.toString());
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> SelectedArea(String value) async {
    try {
      final uri = Uri.parse('${api}/cust');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('location', value);
      username = prefs.getString('user');
      prefs.getString('user');
      final requestBody = {
        'area' : locationcontroller.text,
        'compcode': '${prefs.getString('comp')}',
      };
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          SelectedData = data['data'];
          print(SelectedData.toString());
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String getTypeDescription(String custType) {
    if (custType == '1') {
      return 'retail';
    } else {
      return 'wholesale';
    }
  }


  TextEditingController locationcontroller = TextEditingController();
  TextEditingController selectedController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: app_color,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                  // user_name,
                  '$user',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: Text(
                'Orders',
                style: GoogleFonts.poppins(),
              ),
            ),
            // ListTile(
            //   leading: const Icon(Icons.shopping_cart),
            //   title: Text(
            //     'Balance',
            //     style: GoogleFonts.poppins(),
            //   ),
            // ),
            GestureDetector(
              onTap: ()async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
              },
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: Text(
                  'Logout',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40,left: 20,right: 10),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: Icon(Icons.menu, color: app_color, size: 35),
                      );
                    },
                  ),
                  SizedBox(
                    width: 180,
                    child: CustomAutoCompleteTextField(
                      suggestions: finalData,
                      hintText: 'Location',
                      controller: locationcontroller,
                      onChanged: (value) {
                        setState(() {
                        });
                      },
                      onSubmitted: (value) {
                        // setState(() {});
                        SelectedArea(value);
                        print(value);
                      },
                    ),
                  ),
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
              //   child: Divider(color: app_color, thickness: 2),
              // ),
              AreaFilter(
                suggestions: SelectedData,
                hintText: 'Item Search',
                controller: selectedController,
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: (value) {
                  setState(() {});
                },
              ),
              Expanded(
                  child: ListView.builder(
                    itemCount: SelectedData.length,
                    itemBuilder: (context, index) {
                      // Check if selectedName is not null and filter by cust_name
                      if (selectedName != null &&
                          SelectedData[index]['cust_name'] != selectedName) {
                        // Skip this item if it doesn't match the selected cust_name
                        return SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ItemsPage(item: SelectedData[index]),));
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Container(
                            // height: MediaQuery.of(context).size.height/5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: app_color),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(SelectedData[index]['cust_name'],
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500, fontSize: 20),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    SelectedData[index]['cust_area'],
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.grey.shade600)),
                                                Text(
                                                    SelectedData[index]['cust_address'],
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.grey.shade600)),
                                                Text(
                                                    'Ph : ${SelectedData[index]['cust_phone']}',
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.grey.shade600)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: app_color,
                                            borderRadius: BorderRadius.circular(8)),
                                        child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                              child: Text('${getTypeDescription(SelectedData[index]['cust_type'],)}',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white),
                                              ),
                                            )),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CustomAutoCompleteTextField extends StatefulWidget {
  const CustomAutoCompleteTextField(
      {Key? key,
        required this.suggestions,
        required this.hintText,
        required this.controller,
        this.onSubmitted,
        required this.onChanged})
      : super(key: key);
  final List suggestions; // List of suggestions for AutoCompleteTextField
  final String hintText; // Hint text for the field
  final TextEditingController controller;
  final ValueChanged<String>?
  onSubmitted; // Callback when user submits a suggestion
  final ValueChanged<String> onChanged;
  @override
  State<CustomAutoCompleteTextField> createState() => _CustomAutoCompleteTextFieldState();
}

class _CustomAutoCompleteTextFieldState extends State<CustomAutoCompleteTextField> {
  // Callback when user changes the input
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TypeAheadFormField(
          enabled: false,
          autoFlipMinHeight: 10,
          minCharsForSuggestions: 1,
          textFieldConfiguration: TextFieldConfiguration(
            textCapitalization: TextCapitalization.words,
            controller: widget.controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(suffixIcon:Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              // child: Icon(sufix,color: Colors.grey,size: 30,),
            ) ,errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2,
                    color:  Color.fromARGB(255, 31, 65, 188).withOpacity(.5)), // Border color when not in focus
              ),
              hintText: 'Location',
              labelStyle: GoogleFonts.poppins(color: Colors.black.withOpacity(.8)),
              fillColor: Colors.white,
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
          ),
          suggestionsCallback: (pattern) async{

            return widget.suggestions.where((item) => item['cust_area'].toLowerCase().contains(pattern.toLowerCase()));
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion['cust_area']),
              // subtitle: Text(suggestion['cust_name']),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (suggestion) {
            widget.controller.text = suggestion['cust_area'];
            widget.onSubmitted!(suggestion['cust_area']);
          },
        ),
      ),
    );
  }
}

class AreaFilter extends StatefulWidget {
  const AreaFilter(
      {Key? key,
        required this.suggestions,
        required this.hintText,
        required this.controller,
        this.onSubmitted,
        required this.onChanged})
      : super(key: key);
  final List suggestions; // List of suggestions for AutoCompleteTextField
  final String hintText; // Hint text for the field
  final TextEditingController controller;
  final ValueChanged<String>?onSubmitted; // Callback when user submits a suggestion
  final ValueChanged<String> onChanged;
  @override
  State<AreaFilter> createState() => _AreaFilterState();
}

class _AreaFilterState extends State<AreaFilter> {
  // Callback when user changes the input
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TypeAheadFormField(
        enabled: false,
        autoFlipMinHeight: 10,
        minCharsForSuggestions: 1,
        textFieldConfiguration: TextFieldConfiguration(
          textCapitalization: TextCapitalization.words,
          controller: widget.controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(suffixIcon:Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
            // child: Icon(sufix,color: Colors.grey,size: 30,),
          ) ,errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  width: 2,
                  color:  app_color.withOpacity(.5)), // Border color when not in focus
            ),
            hintText: 'Shop Search',
            labelStyle: GoogleFonts.poppins(color: Colors.black.withOpacity(.8)),
            fillColor:  Colors.white,
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
        ),
        suggestionsCallback: (pattern) async{

          return widget.suggestions.where((item) => item['cust_name'].toLowerCase().contains(pattern.toLowerCase()));
        },

        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion['cust_name']),
            // subtitle: Text(suggestion['cust_name']),
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (suggestion) {

          // widget.controller.text = suggestion['cust_name'];
          setState(() {
            selectedName = suggestion['cust_name'];
          });
          widget.onSubmitted!(suggestion['cust_name']);
        },
      ),
    );
  }
}