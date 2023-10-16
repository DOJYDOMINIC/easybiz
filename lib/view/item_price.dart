import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../const.dart';
import 'company_data.dart';
import 'itemspage.dart';

class ItemsPageData extends StatefulWidget {
  const ItemsPageData({super.key, this.data});

  final data;

  @override
  State<ItemsPageData> createState() => _ItemsPageDataState();
}

class _ItemsPageDataState extends State<ItemsPageData> {
  @override
  void initState() {
    super.initState();
    ItemCall();
  }

  TextEditingController itemcontroller = TextEditingController();
  List itemdatalist = [];

  Future<void> ItemCall() async {
    try {
      final uri = Uri.parse('${api}/items');
      SharedPreferences prefs = await SharedPreferences.getInstance();

      comp = prefs.getString('comp')!;
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

        if (data['data'] != []) {
          itemdatalist = data['data'];
          print(itemdatalist.toString());
        }

        // print(itemdatalist.toString());
      } else {
        print('Error: ${comp}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Items List',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: itemcontroller,
                onChanged: (pattern) {
                  setState(() {
                    itemdatalist.where((item) => item['item_name']
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
                  hintText: 'Item Search',
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
              ),
            ),
            Expanded(
              child: itemdatalist.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: itemdatalist.length,
                      itemBuilder: (context, index) {
                        if (itemdatalist.isEmpty ||
                            !itemdatalist[index]['item_name']
                                .toLowerCase()
                                .contains(itemcontroller.text.toLowerCase())) {
                          return SizedBox.shrink();
                        }

                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemdatalist[index]['item_name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildItemInfo(
                                        'Qty',
                                        itemdatalist[index]['item_qty']
                                            .toString()),
                                    _buildItemInfo(
                                        'Retail',
                                        itemdatalist[index]['item_price1']
                                            .toString()),
                                    _buildItemInfo(
                                        'Wholesale',
                                        itemdatalist[index]['item_price2']
                                            .toString()),
                                    _buildItemInfo(
                                        'Special',
                                        itemdatalist[index]['item_price3']
                                            .toString()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfo(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
