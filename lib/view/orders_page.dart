import 'package:EzBiz/const.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List orderList = [];

  TextEditingController orderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onTap: () {},
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 25, top: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (BuildContext context) {
                            return IconButton(
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                              icon:
                                  Icon(Icons.menu, color: app_color, size: 35),
                            );
                          },
                        ),
                        Column(
                          children: [
                            Text('Name'),
                            Container(
                              height: 15,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: app_color,
                                  borderRadius: BorderRadius.circular(15)),
                            )
                          ],
                        )
                      ]),
                ),
                Divider(
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: orderController,
                    onChanged: (pattern) {
                      setState(() {
                        setState(() {});
                        orderList.where((item) => item['cust_area']
                            .toLowerCase()
                            .startsWith(pattern.toLowerCase()));
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
                            color: app_color.withOpacity(
                                .3)), // Border color when not in focus
                      ),
                      hintText: 'Order Search',
                      labelStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(.8)),
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
                    child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Dismissible(
                        key: Key('10'),
                        onDismissed: (direction) {
                          setState(() {
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              // color: app_color,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10)),
                          height: 150,
                        ),
                      ),
                    );
                  },
                ))
              ],
            ),
          ),
        ));
  }
}
