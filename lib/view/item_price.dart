import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../const.dart';
import 'company_data.dart';

class ItemsPageData extends StatefulWidget {
  const ItemsPageData({Key? key, this.data});

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
  List filteredItemList = [];


  Future<void> ItemCall() async {
    try {
      final uri = Uri.parse('$api/items');
      SharedPreferences prefs = await SharedPreferences.getInstance();

      comp = prefs.getString('comp')!;

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
          itemdatalist = data['data'];
          filteredItemList = List.from(itemdatalist);
        });
      } else {
        print('Error: ${comp}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void sortItemList() {
    setState(() {
      itemdatalist.sort((a, b) =>
          a['item_name'].toLowerCase().compareTo(b['item_name'].toLowerCase()));
      filteredItemList = List.from(itemdatalist);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items List'),
        backgroundColor: app_color,
      ),
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
                    filteredItemList = itemdatalist.where((item) =>
                        item['item_name']
                            .toLowerCase()
                            .contains(pattern.toLowerCase())).toList();
                  });
                },
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 2,
                      color: app_color.withOpacity(.3),
                    ),
                  ),
                  hintText: 'Item Search',
                  labelStyle: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(.8)),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 2,
                      color: app_color,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredItemList.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: filteredItemList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filteredItemList[index]['item_name'],
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
                                  filteredItemList[index]['item_qty']
                                      .toString()),
                              _buildItemInfo(
                                  'Retail',
                                  filteredItemList[index]['item_price1']
                                      .toString()),
                              _buildItemInfo(
                                  'Wholesale',
                                  filteredItemList[index]['item_price2']
                                      .toString()),
                              _buildItemInfo(
                                  'Special',
                                  filteredItemList[index]['item_price3']
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: sortItemList,
      //   child: Icon(Icons.sort),
      // ),
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
