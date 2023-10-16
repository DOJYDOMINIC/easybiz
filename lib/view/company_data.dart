import 'dart:convert';
import 'package:easybiz/view/item_price.dart';
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
String? custarea;
String? usercode;
String comp ='';


class CompanyData extends StatefulWidget {
  const CompanyData({super.key});

  @override
  State<CompanyData> createState() => _CompanyDataState();
}

class _CompanyDataState extends State<CompanyData> {
  List SelectedData = [];

  @override
  void initState() {
    super.initState();
    SelectedArea();
    custarea;
    ItemCall();
  }


  void Area()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('location', locationcontroller.text);
  }

  Future<void> ItemCall() async {
    try {
      final uri = Uri.parse('${api}/items');
      SharedPreferences prefs = await SharedPreferences.getInstance();

      location = prefs.getString('location');
      // comp = prefs.getString('comp');
      final requestBody = {
        'compcode': comp,
        // 'custcode': widget.item['cust_code'],
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
        // if (data['data'] != []) {
        itemdata = data['data'];
        // }

        print(itemdata.toString());
      } else {
        print('Error: ${comp}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  Future<void> SelectedArea() async {
    try {
      try{
        if (mounted) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          custarea = prefs.getString('location');
          usercode = prefs.getString('usercode');
          comp = prefs.getString('comp')!;

          comp = prefs.getString('comp')??'';
          if (custarea != null) {
            setState(() {
              locationcontroller.text = custarea!;
            });
          } else {
            setState(() {
              locationcontroller;
            });
          }
        }
      }catch(e){
        print('locationcontroller $e');
      }

      final uri = Uri.parse('${api}/cust');

      // prefs.getString('user');
      final requestBody = {
        'compcode': comp,
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
    if (custType == 'R') {
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
            GestureDetector(
              onTap: (){
                SelectedArea();
                Navigator.pop(context);
              },
              child: ListTile(
                leading: const Icon(Icons.home),
                title: Text(
                  'Home',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ItemsPageData(data:SelectedData)));
              },
              child: ListTile(
                leading: const Icon(Icons.attach_money_outlined),
                title: Text(
                  'Price List',
                  style: GoogleFonts.poppins(),
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

            GestureDetector(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ));
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
        padding: const EdgeInsets.only(top: 40, left: 20, right: 10),
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
                      suggestions: SelectedData,
                      hintText: 'Location',
                      controller: locationcontroller,
                      onChanged: (value) {
                        setState(() {});
                      },
                      onSubmitted: (value) {
                        Area();
                        // setState(() {});
                        // SelectedArea();
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                controller: selectedController,
                onChanged: (pattern) {
                  setState(() {
                    SelectedData.where((item) => item['cust_area']
                        .toLowerCase()
                        .contains(pattern.toLowerCase()));
                  });
                },
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  ),
                  errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        width: 2,
                        color: app_color
                            .withOpacity(.3)), // Border color when not in focus
                  ),
                  hintText: 'Shop Search',
                  labelStyle:
                      GoogleFonts.poppins(color: Colors.black.withOpacity(.8)),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        width: 2,
                        color: app_color), // Border color when focused
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white)),
                ),
//         ),
              ),
              // AreaFilter(
              //   suggestions: SelectedData,
              //   hintText: 'Item Search',
              //   controller: selectedController,
              //   onChanged: (value) {
              //     setState(() {});
              //   },
              //   onSubmitted: (value) {
              //     setState(() {});
              //   },
              // ),
              SizedBox(height: 15),
              Expanded(
                  child:SelectedData.isEmpty ? Center(child: CircularProgressIndicator()) : ListView.builder(
                itemCount: SelectedData.length,
                itemBuilder: (context, index) {
                  // Check if selectedName is not null and filter by cust_name
                  if (selectedController.text.isNotEmpty &&
                      !SelectedData[index]['cust_name']
                          .toLowerCase()
                          .contains(selectedController.text.toLowerCase())  || locationcontroller.text.isNotEmpty &&
                      !SelectedData[index]['cust_area']
                          .toLowerCase()
                          .contains(locationcontroller.text.toLowerCase())) {
                    return SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemsPage(item: SelectedData[index]),
                          ));
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
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width:200,
                                        child: Text(
                                          SelectedData[index]['cust_name'],
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: app_color,
                                            borderRadius: BorderRadius.circular(8)),
                                        child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                              child: Text(
                                                '${getTypeDescription(SelectedData[index]['cust_type'],
                                                )}',

                                                style: GoogleFonts.poppins(
                                                    color: Colors.white),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            SelectedData[index]
                                                ['cust_area'],
                                            style: GoogleFonts.poppins(
                                                color:
                                                    Colors.grey.shade600)),
                                        Text(
                                            SelectedData[index]
                                                ['cust_address'],
                                            overflow:TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                                color:
                                                    Colors.grey.shade600)),
                                        Text(
                                            'Ph : ${SelectedData[index]['cust_phone']}',
                                            style: GoogleFonts.poppins(
                                                color:
                                                    Colors.grey.shade600)),
                                      ],
                                    ),
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
              )),
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
  State<CustomAutoCompleteTextField> createState() =>
      _CustomAutoCompleteTextFieldState();
}

class _CustomAutoCompleteTextFieldState
    extends State<CustomAutoCompleteTextField> {
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
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                // child: Icon(sufix,color: Colors.grey,size: 30,),
              ),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2,
                    color: app_color
                        .withOpacity(.3)), // Border color when not in focus
              ),
              hintText: 'Location',
              labelStyle:
                  GoogleFonts.poppins(color: Colors.black.withOpacity(.8)),
              fillColor: Colors.white,
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: app_color), // Border color when focused
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          suggestionsCallback: (pattern) {
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

// class AreaFilter extends StatefulWidget {
//   const AreaFilter(
//       {Key? key,
//         required this.suggestions,
//         required this.hintText,
//         required this.controller,
//         this.onSubmitted,
//         required this.onChanged})
//       : super(key: key);
//   final List suggestions; // List of suggestions for AutoCompleteTextField
//   final String hintText; // Hint text for the field
//   final TextEditingController controller;
//   final ValueChanged<String>?onSubmitted; // Callback when user submits a suggestion
//   final ValueChanged<String> onChanged;
//   @override
//   State<AreaFilter> createState() => _AreaFilterState();
// }
//
// class _AreaFilterState extends State<AreaFilter> {
//   // Callback when user changes the input
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TypeAheadFormField(
//         enabled: false,
//         autoFlipMinHeight: 10,
//         minCharsForSuggestions: 1,
//         textFieldConfiguration: TextFieldConfiguration(
//           textCapitalization: TextCapitalization.words,
//           controller: widget.controller,
//           onChanged: widget.onChanged,
//           decoration: InputDecoration(suffixIcon:Padding(
//             padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
//             // child: Icon(sufix,color: Colors.grey,size: 30,),
//           ) ,errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(
//                   width: 2,
//                   color:  app_color.withOpacity(.5)), // Border color when not in focus
//             ),
//             hintText: 'Shop Search',
//             labelStyle: GoogleFonts.poppins(color: Colors.black.withOpacity(.8)),
//             fillColor:  Colors.white,
//             filled: true,
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(
//                   width: 2,
//                   color:app_color), // Border color when focused
//             ),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 borderSide: BorderSide(color: Colors.white)),
//
//           ),
//         ),
//         suggestionsCallback: (pattern) async{
//
//           return widget.suggestions.where((item) => item['cust_name'].toLowerCase().contains(pattern.toLowerCase()));
//         },
//
//         itemBuilder: (context, suggestion) {
//           return ListTile(
//             title: Text(suggestion['cust_name']),
//             // subtitle: Text(suggestion['cust_name']),
//           );
//         },
//         transitionBuilder: (context, suggestionsBox, controller) {
//           return suggestionsBox;
//         },
//         onSuggestionSelected: (suggestion) {
//
//           // widget.controller.text = suggestion['cust_name'];
//           setState(() {
//             selectedName = suggestion['cust_name'];
//           });
//           widget.onSubmitted!(suggestion['cust_name']);
//         },
//       ),
//     );
//   }
// }
