import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';
import 'dart:io';
import 'company_data.dart';
import 'item_price.dart';
import 'login.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

String itemname = '';
num? grandTotal;
String? location;
num? count = 1;
List itemdata = [];

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
    // ItemCall();
    _getCurrentLocation();
    count = 1;
  }

  double latitude = 0.0;
  double longitude = 0.0;

  String deviceModel = '';

  void clear() {
    itemController.clear();
  }

  Future<void> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.name;
      // print(deviceModel);
    } else {
      deviceModel = 'Unknown';
      // print(deviceModel);
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
    });
  }

  // var count;
  List filterList = [];
  List Grandtotal = [];

  // List<Map<String,dynamic>> datalist  = [];

  List<TextEditingController> itemControllers = [];

  TextEditingController itemController = TextEditingController();

  // TextEditingController itemControllers = TextEditingController();
  // int total = calculateTotal();

  num calculateTotal() {
    num total = 0;
    if (itemControllers.isNotEmpty) {
      for (int index = 0; index < filterList.length; index++) {
        num itemPrice1 =
            num.parse(pricelist(widget.item['cust_type'].toString(), index));
        num count = int.tryParse(itemControllers[index].text) ?? 0;
        total += itemPrice1 * count;
      }
    }
    return total;
  }

  String getTypeDescription(String custType) {
    if (custType == 'R') {
      return 'retail';
    } else {
      return 'wholesale';
    }
  }

  String? formattedDate;
  String? formattedTime;

  List<Map<String, dynamic>> orderData = [];
  List<Map<String, dynamic>> dataList = [];

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
      itemprice = filterList[i]['item_price1'].toString();
      num value =
          filterList[i]['item_price1'] * num.tryParse(controller.toString());
      itemqty = value.toString();
      // Do something with itemCode
      orderData.add({
        'comp_code': comp,
        'ord_date': '${DateTime.now().toString()}',
        'ord_time': '${DateTime.now().toString()}',
        'item_code': itemCode,
        'item_name': itemnames,
        'item_qty': controller,
        'item_price': itemprice,
        'item_tax': 0.0,
        'item_disc': 0.0,
        'item_cess': 0.0,
        'trx_total': itemqty,
        'status_flag': "0",
        'act_code': "${widget.item['cust_code']}",
        'act_name': '${widget.item['cust_name']}',
        'act_address': "${widget.item['cust_address']}",
        'act_phone': "${widget.item['cust_phone']}",
        'act_area': "${widget.item['cust_area']}",
        'act_type': "${widget.item['cust_type']}",
        'trx_disc': 0.0,
        'trx_netamount': 0.0,
        'user_code': usercode,
        'user_name': user,
        'lat_long':
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        'system_name': "$deviceModel",
        'grand_total': "${calculateTotal()}"
      });
    }
  }

  String Itembill = '';

  String createOrderTables(List<Map<String, dynamic>> dataList) {
    String orderText = '';
    for (int i = 0; i < dataList.length; i++) {
      Map<String, dynamic> data = dataList[i];

      orderText += '| Field | Value |\n';
      orderText += '| --- | --- |\n';
      orderText += '| Order Date | ${data['ord_date']} |\n';
      orderText += '| Item Name | ${data['item_name']} |\n';
      orderText += '| Item Quantity | ${data['item_qty']} |\n';
      orderText += '| Item Price | ${data['item_price']} |\n';
      orderText += '| Customer Name | ${data['act_name']} |\n';
      orderText += '| Customer Address | ${data['act_address']} |\n';
      orderText += '| Customer Phone | ${data['act_phone']} |\n';
      orderText += '| Customer Area | ${data['act_area']} |\n';
      orderText += '| Customer Type | ${data['act_type']} |\n';
      orderText += '| User Code | ${data['user_code']} |\n';
      orderText += '| User Name | ${data['user_name']} |\n';
      orderText += '| Grand Total | ${data['grand_total']} |\n';

      // Add a separator between tables if there are more to come
      if (i < dataList.length - 1) {
        orderText += '\n---\n\n';
      }
    }
    return orderText;
  }

  // Future<void> _generateAndSharePDF(List<Map<String, dynamic>> dataList) async {
  //   final pdf = pw.Document();
  //
  //   String orderText = createOrderTables(dataList);
  //
  //   pdf.addPage(pw.Page(build: (pw.Context context) {
  //     return pw.Center(
  //       child: pw.Column(children: [
  //         pw.Text('Order Details', style: pw.TextStyle(fontSize: 20)),
  //         pw.Text(orderText),
  //       ]),
  //     );
  //   }));
  //
  //   // Save the PDF
  //   final output = await getTemporaryDirectory();
  //   final file = File("${output.path}/order${DateTime.now()}.pdf");
  //   await file.writeAsBytes(await pdf.save());
  //
  //   // Share the PDF
  //   Share.shareFiles([file.path], text: 'Sharing PDF from Flutter');
  // }

  Future<void> createOrderAPI(List<Map<String, dynamic>> value) async {
    try {
      final url = Uri.parse('$api/order'); // Replace with your endpoint

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(value),
      );

      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);

        final dataList = data['ord_mast'][0]['ord_no'];
        print(dataList.toString());
        print(orderData.toString());
        orderData.clear();
        filterList.clear();
        itemControllers.clear();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Order Conformed'),
              content: Text('Order NO : $dataList'),
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      // createOrderTables(orderData);
                      // _generateAndSharePDF(orderData);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.share)),
                TextButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompanyData(),
                        ));
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle failure
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Order Failed'),
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
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String pricelist(String custType, int index) {
    if (custType == 'R') {
      return filterList[index]['item_price1'].toString();
    } else if (custType == 'W') {
      return filterList[index]['item_price2'].toString();
    }
    // Handle other cases or return a default value if necessary
    return filterList[index]
        ['item_price2']; // Change this to your appropriate default value
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
        resizeToAvoidBottomInset: true,
        drawer: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Drawer(
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemsPageData()));
                  },
                  child: ListTile(
                    leading: const Icon(Icons.currency_rupee),
                    title: Text(
                      'Price List',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: Text(
                      'Orders',
                      style: GoogleFonts.poppins(),
                    ),
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
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
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
                      GestureDetector(
                        onTap: () {
                          // print(itemdata.toString());
                        },
                        child: Container(
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
                  setState(() {
                    itemController.clear();
                  });
                },
                onItemSelected: (selectedItem) {
                  // Check if the selected item already exists in filterList
                  itemControllers.add(TextEditingController(text: '1'));
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
                  child: filterList == null
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: filterList.length,
                          itemBuilder: (context, index) {
                            // itemControllers.add(TextEditingController(text: '1'));
                            return Column(
                              children: [
                                Dismissible(
                                  key: Key(filterList[index]['item_name']),
                                  onDismissed: (direction) {
                                    setState(() {
                                      filterList.removeAt(index);
                                      itemControllers.removeAt(index);
                                      orderData.remove(index);
                                      grandTotal = calculateTotal();
                                    });
                                  },
                                  background: Container(
                                    color: Colors.red,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 20, 0),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 200,
                                              child: Text(
                                                filterList[index]['item_name'],
                                                style: GoogleFonts.poppins(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                // Text('${filterList[index]['item_qty'] - itemController}', style: GoogleFonts.poppins()),
                                                Column(
                                                  children: [
                                                    Text('Qty',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                    Text(
                                                        '${filterList[index]['item_qty']}',
                                                        style: GoogleFonts
                                                            .poppins()),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, right: 20),
                                                  child: Column(
                                                    children: [
                                                      Text('price',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                      Text(
                                                          '${pricelist(widget.item['cust_type'].toString(), index)}',
                                                          style: GoogleFonts
                                                              .poppins()),
                                                    ],
                                                  ),
                                                ),

                                                Column(
                                                  children: [
                                                    Text('Total',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                    Text(
                                                      '${(num.parse(pricelist(widget.item['cust_type'], index)) * (num.tryParse(itemControllers[index].text) ?? 0)).toStringAsFixed(2)}',
                                                      style: GoogleFonts.poppins(),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              child: CircleAvatar(
                                                backgroundColor: num.tryParse(
                                                            itemControllers[
                                                                    index]
                                                                .text)! <=
                                                        1
                                                    ? Colors.grey
                                                    : app_color,
                                                child: const Text('-',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (num.tryParse(
                                                          itemControllers[index]
                                                              .text)! >
                                                      1) {
                                                    num count = num.tryParse(
                                                            itemControllers[
                                                                    index]
                                                                .text) ??
                                                        0;
                                                    count--;
                                                    itemControllers[index]
                                                            .text =
                                                        count.toString();

                                                    // Update your total or other calculations here
                                                  }
                                                });
                                              },
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: TextField(
                                                controller:
                                                    itemControllers[index],
                                                onChanged: (value) {
                                                  setState(() {
                                                    var newValue =
                                                        num.tryParse(value) ??
                                                            0;
                                                    // if (newValue != null) {
                                                    //   if (newValue > ) {
                                                    count = newValue;
                                                    grandTotal =
                                                        calculateTotal();
                                                    // Update your total or other calculations here
                                                    // } else {
                                                    //   // Show an alert dialog if the count exceeds the stock
                                                    //   count = newValue;
                                                    //   showDialog(
                                                    //     context: context,
                                                    //     builder:
                                                    //         (BuildContext context) {
                                                    //       return AlertDialog(
                                                    //         title: Text('Invalid Count'),
                                                    //         content: Text('Enter a Proper Value Count'),
                                                    //         actions: <Widget>[
                                                    //           TextButton(
                                                    //             onPressed: () {
                                                    //               Navigator.of(context).pop();
                                                    //             },
                                                    //             child: Text('OK'),
                                                    //           ),
                                                    //         ],
                                                    //       );
                                                    //     },
                                                    //   );
                                                    // Reset the TextField value to the current item count
                                                    itemControllers[index]
                                                            .text =
                                                        count.toString();
                                                    // }
                                                    // }
                                                  });
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  border: UnderlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              child: CircleAvatar(
                                                backgroundColor: app_color,
                                                child: const Text('+',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  num count = num.tryParse(
                                                          itemControllers[index]
                                                              .text) ??
                                                      0;
                                                  count++;
                                                  itemControllers[index].text =
                                                      count.toString();
                                                  // grandTotal = calculateTotal();
                                                  // print(itemControllers[0].text);
                                                  // Update your total or other calculations here
                                                  // print("${filterList[index]['item_qty'].runtimeType}");
                                                  if (itemControllers[index]
                                                          .text ==
                                                      filterList[index]
                                                              ['item_qty']
                                                          .toString()) {
                                                    // print("call function");
                                                  }
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: app_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            15), // Set the border radius here
                      ), // Set the background color of the button
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // int total = 0;
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            title: Center(
                                child: Text(
                              'Do you want to confirm ?',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            )),
                            content: Container(
                              height: 50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Note : Confirmed order cannot be edited !',
                                    style: TextStyle(
                                      fontSize: 11,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      'Amount  :  ${calculateTotal().toString()}'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              Colors.black, // text color
                                        ),
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              app_color, // text color
                                        ),
                                        child: Text('Confirm'),
                                        onPressed: () {
                                          // Add your logic if the user confirms
                                          setState(() {
                                            Purchase_data();
                                            createOrderAPI(orderData);
                                            getDeviceName();
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      // print(filterList.toString());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Place Order : ₹${calculateTotal().toStringAsFixed(2)} '),
                        // Text('${calculateTotal().toStringAsFixed(2)}',style: GoogleFonts.poppins(fontSize: 18),),
                      ],
                    ),
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
                      .startsWith(pattern.toLowerCase()))
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
                          Row(
                            children: [
                              Text('stock : ', style: TextStyle(fontSize: 15)),
                              Text(suggestion['item_qty'].toString(),
                                  style: TextStyle(fontSize: 15)),
                            ],
                          ),
                          Row(
                            children: [
                              Text('price : ', style: TextStyle(fontSize: 15)),
                              Text(suggestion['item_price1'].toString(),
                                  style: TextStyle(fontSize: 15)),
                            ],
                          ),
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
