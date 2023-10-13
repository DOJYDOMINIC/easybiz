import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:easybiz/main.dart';
import 'package:easybiz/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';
import 'company_data.dart';
import 'dart:io';

import 'login.dart';

String itemname = '';
int? grandTotal;
String? location;
num count = 1;

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key, this.item});

  final item;

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  @override
  void initState() {
    super.initState();
    ItemCall();
    _getCurrentLocation();
    print(widget.item.toString());
    count = 1;
  }

  double latitude = 0.0;
  double longitude = 0.0;

  String deviceModel = '';

  Future<void> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      print(deviceModel);
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.name;
      print(deviceModel);
    } else {
      deviceModel = 'Unknown';
      print(deviceModel);
    }
  }

  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the scenario when the location permission is denied by the user
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the scenario when the location permission is permanently denied by the user
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      print('${latitude}');
      print('${longitude}');
    });
  }

  var count;
  List itemdata = [];
  List filterList = [];
  List Grandtotal = [];
  List<TextEditingController> itemControllers = [];

  TextEditingController itemController = TextEditingController();

  // TextEditingController itemControllers = TextEditingController();

  // String? user_name;
  int calculateTotal() {
    int total = 0;
    for (int index = 0; index < filterList.length; index++) {
      int itemPrice1 = filterList[index]['item_price1'];
      int count = int.tryParse(itemControllers[index].text) ?? 0;
      total += itemPrice1 * count;
    }
    return total;
  }

  String getTypeDescription(String custType) {
    if (custType == '1') {
      return 'retail';
    } else {
      return 'wholesale';
    }
  }

  Future<void> ItemCall() async {
    try {
      final uri = Uri.parse('${api}/items');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      location = prefs.getString('location');
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
        if (data['data'] != []) {
          itemdata = data['data'];
        }

        print(itemdata.toString());
      } else {
        print('Error: ${comp}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // dynamic Orderdata = [];
  String? formattedDate;
  String? formattedTime;

  List<Map<String, dynamic>> orderData = [];

  String? itemCode;
  String? itemnames;
  String? controller;
  String? itemqty;
  String? itemprice;

  void Purchase_data() {
    for (int i = 0; i < filterList.length; i++) {
       itemCode = filterList[i]['item_code'];
       itemnames = filterList[i]['item_name'];
       controller = itemControllers[i].text.toString();
       itemprice   =  filterList[i]['item_price1'].toString();
    int value =  filterList[i]['item_price1'] * int.tryParse(controller.toString());
       itemqty = value.toString();
     print(i);
      // Do something with itemCode
       orderData.add({
         'compCode': comp,
         'ordDate': '${DateTime.now().toString()}',
         'ordTime': '${DateTime.now().toString()}',
         'itemCode': itemCode,
         'itemName': itemnames,
         'itemQty': controller,
         'itemPrice': itemprice,
         'itemTax': null,
         'itemDisc': null,
         'itemCess': null,
         'trxTotal': itemqty,
         'statusFlag': "0",
         'actCode': "${widget.item['cust_code']}",
         'actName':'${widget.item['cust_name']}',
         'actAddress': "${widget.item['cust_address']}",
         'actPhone': "${widget.item['cust_phone']}",
         'actArea': location,
         'actType': "${widget.item['cust_type']}",
         'trxDisc': null,
         'trxNetamount': null,
         'userCode': usercode,
         'userName': user,
         'latLong': '${latitude},${longitude}',
         'systemName': "$deviceModel",
         'grandtotal': "$grandTotal"
       });
    }

  }

  Future<void> createOrderAPI(List<Map<String, dynamic>> orders) async {
    final url = Uri.parse('${api}/order'); // Replace with your endpoint

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(orderData),
    );

    if (response.statusCode == 200) {
      // Handle success
      orderData.clear();
      print('Order placed successfully');
    } else {
      // Handle failure
      print('Failed to place order. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!FocusScope.of(context).hasPrimaryFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: BottomAppBar(
            elevation: 0,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: app_color,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15), // Set the border radius here
                  ), // Set the background color of the button
                ),
                onPressed: () {
                  Purchase_data();
                  createOrderAPI(orderData);
                  getDeviceName();
                  print(filterList.toString());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Place Order : ₹${grandTotal ?? 0} '),
                    // Text('${calculateTotal().toStringAsFixed(2)}',style: GoogleFonts.poppins(fontSize: 18),),
                  ],
                ),
              ),
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: app_color,
                ),
                child:
                    // user_name,
                    Text(
                  // user_name,
                  '$user',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text(
                  'Balance',
                  style: GoogleFonts.poppins(),
                ),
              ),
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
          padding: const EdgeInsets.fromLTRB(10, 50, 20, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 25,
                        decoration: BoxDecoration(
                            color: app_color,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            '${getTypeDescription(
                              widget.item['cust_type'],
                            )}',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        )),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${widget.item['cust_name']}',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black)),
                          Text('${widget.item['cust_address']}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey.shade600)),
                          Text(
                            '${widget.item['cust_phone']}',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                child: Divider(color: app_color, thickness: 2),
              ),
              ItemFilter(
                suggestions: itemdata,
                hintText: 'Search Item',
                controller: itemController,
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: (value) {
                  setState(() {});
                },
                onItemSelected: (selectedItem) {
                  // Check if the selected item already exists in filterList
                  bool itemAlreadyExists = filterList.any((item) {
                    return item['item_name'] == selectedItem['item_name'];
                  });

                  if (itemAlreadyExists) {
                    // Item already exists, show a Snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${selectedItem['item_name']} is already added.'),
                      ),
                    );
                  } else {
                    // Item doesn't exist, add it to the list
                    filterList.add(selectedItem);
                  }
                },
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: filterList.length,
                itemBuilder: (context, index) {
                  itemControllers.add(TextEditingController());
                  // Check if selectedName is not null and filter by cust_name
                  // if (selectedName != null &&
                  //     filterList[index]['item_name'] != selectedName) {
                  //   // Skip this item if it doesn't match the selected cust_name
                  //   return SizedBox.shrink();
                  // }
                  return Column(
                    children: [
                      Dismissible(
                        key: Key(filterList[index]['item_name']),
                        onDismissed: (direction) {
                          setState(() {
                            filterList.removeAt(index);
                            grandTotal = calculateTotal();
                            itemControllers[index].clear();
                          });
                        },
                        background: Container(
                          color: Colors.red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filterList[index]['item_name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      // Text('${filterList[index]['item_qty'] - itemController}', style: GoogleFonts.poppins()),
                                      Text('${filterList[index]['item_qty']}',
                                          style: GoogleFonts.poppins()),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: Text(
                                            '${filterList[index]['item_price1']}',
                                            style: GoogleFonts.poppins()),
                                      ),

                                      Text(
                                          '${filterList[index]['item_price1'] * (int.tryParse(itemControllers[index].text) ?? 0)}',
                                          style: GoogleFonts.poppins()),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    child: CircleAvatar(
                                      backgroundColor: app_color,
                                      child: const Text('-',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (count > 0) {
                                          itemControllers[index].text =
                                              count.toString();
                                          count--;
                                          grandTotal = calculateTotal();

                                          // Update your total or other calculations here
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: itemControllers[index],
                                      onChanged: (value) {
                                        setState(() {
                                          var newValue = int.tryParse(value);
                                          if (newValue != null) {
                                            if (newValue > 0) {
                                              count = newValue;
                                              grandTotal = calculateTotal();

                                              // Update your total or other calculations here
                                            } else {
                                              // Show an alert dialog if the count exceeds the stock
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Invalid Count'),
                                                    content: Text(
                                                        'Enter a Proper Value Count'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('OK'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              // Reset the TextField value to the current item count
                                              itemControllers[index].text =
                                                  count.toString();
                                            }
                                          }
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: CircleAvatar(
                                      backgroundColor: app_color,
                                      child: const Text('+',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        // if (count != 10000) {
                                        itemControllers[index].text = count.toString();
                                        count++;
                                        grandTotal = calculateTotal();
                                        print(itemControllers[0].text);
                                        print( itemControllers[1].text);
                                        print( itemControllers[2].text);
                                        // Update your total or other calculations here
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 2,
                        color: app_color.withOpacity(.2),
                      ),
                    ],
                  );
                },
              )),
              // ElevatedButton(
              //     onPressed: () {
              //       Purchase_data();
              //     },
              //     child: Text('Add'))
            ],
          ),
        ),
      ),
    );
  }
}

class ItemFilter extends StatefulWidget {
  const ItemFilter({
    Key? key,
    required this.suggestions,
    required this.hintText,
    required this.controller,
    this.onSubmitted,
    required this.onChanged,
    required this.onItemSelected,
  }) : super(key: key);

  final List suggestions;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String> onChanged;

  // Define a callback to handle item selection
  final Function(dynamic) onItemSelected;

  @override
  State<ItemFilter> createState() => _ItemFilterState();
}

class _ItemFilterState extends State<ItemFilter> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey),
        ),
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
                hintText: widget.hintText,
                border: InputBorder.none,
              ),
            ),
            suggestionsCallback: (pattern) async {
              return widget.suggestions
                  .where((item) => item['item_name']
                      .toLowerCase()
                      .contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              final isLastItem = widget.suggestions.indexOf(suggestion) ==
                  widget.suggestions.length - 1;

              return Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(suggestion['item_name'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(suggestion['item_qty'].toString(),
                              style: TextStyle(fontSize: 15)),
                          Text(suggestion['item_price1'].toString(),
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      if (!isLastItem) Divider(thickness: 1.5),
                    ],
                  ),
                ),
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (suggestion) {
              // widget.controller.text = suggestion['item_name'];

              widget.onSubmitted!(suggestion['item_name']);
              // Call the callback to handle the selected item
              widget.onItemSelected(suggestion);
            },
          ),
        ),
      ),
    );
  }
}
