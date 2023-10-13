// if (_searchController.text.isNotEmpty && filtereditemlist.isNotEmpty)
//   ConstrainedBox(
//     constraints: BoxConstraints(
//       minHeight: MediaQuery.of(context).size.height / 8,
//       maxHeight: MediaQuery.of(context).size.height / 4,
//     ),
//     child: Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black26),
//       ),
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: widget.item.length,
//         itemBuilder: (context, index) {
//           final item = filtereditemlist[index];
//           final isItemSelected = selecteditemlist.contains(item);
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 title: Text(item.name),
//                 subtitle: Text('${item.stock}'),
//                 trailing: GestureDetector(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: isItemSelected
//                           ? Colors.grey.withOpacity(0.5)
//                           : app_color,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
//                       child: Text(
//                         isItemSelected ? 'Added' : 'Add',
//                         style: isItemSelected
//                             ? const TextStyle(color: Colors.grey)
//                             : smallbutton,
//                       ),
//                     ),
//                   ),
//                   onTap: () {
//                     if (!isItemSelected) {
//                       setState(() {
//                         selecteditemlist.add(item);
//                         _searchController.clear();
//                       });
//                     }
//                   },
//                 ),
//               ),
//               Divider(
//                 thickness: 2,
//                 color: app_color.withOpacity(.2),
//               )
//             ],
//           );
//         },
//       ),
//     ),
//   ),
// Expanded(
//      child: ListView.builder(
//        itemCount: selecteditemlist.length,
//        itemBuilder: (context, index) {
//          final item = selecteditemlist[index];
//          return Column(
//            children: [
//              Dismissible(
//                key: Key(item.name),
//                onDismissed: (direction) {
//                  setState(() {
//                    selecteditemlist.removeAt(index);
//                  });
//                  ScaffoldMessenger.of(context).showSnackBar(
//                    SnackBar(
//                      content: Text('${item.name} canceled'),
//                    ),
//                  );
//                },
//                background: Container(
//                  color: Colors.red,
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.end,
//                    crossAxisAlignment: CrossAxisAlignment.center,
//                    children: [
//                      Padding(
//                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
//                        child: Text(
//                          'Cancel',
//                          style: GoogleFonts.poppins(
//                            color: Colors.white,
//                            fontSize: 20,
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                child: Padding(
//                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: [
//                      Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: [
//                          Text(item.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),),
//                          const SizedBox(height: 10,),
//                          Row(
//                            children: [
//                              Text('${item.stock - item.count}', style: GoogleFonts.poppins()),
//                              Padding(
//                                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
//                                child: Text('${item.price}', style: GoogleFonts.poppins()),
//                              ),
//                              Text('${item.price * item.count}', style: GoogleFonts.poppins()),
//                            ],
//                          ),
//                        ],
//                      ),
//                      Row(
//                        children: [
//                          GestureDetector(
//                            child: CircleAvatar(
//                              backgroundColor: app_color,
//                              child: const Text('-', style: TextStyle(color: Colors.white)),
//                            ),
//                            onTap: () {
//                              setState(() {
//                                if (item.count > 1) {
//                                  item.count--;
//                                  itemControllers[item]!.text = item.count.toString();
//                                }
//                              });
//                            },
//                          ),
//                          SizedBox(
//                            width: 70,
//                            child: TextField(
//                              controller: itemControllers[item], // Use the controller for this item
//                              onChanged: (value) {
//                                setState(() {
//                                  var newValue = int.tryParse(value);
//                                  if (newValue != null) {
//                                    if (newValue <= item.stock) {
//                                      // Update the count if it's within the stock limit
//                                      item.count = newValue;
//                                    } else {
//                                      // Show an alert dialog if the count exceeds the stock
//                                      showDialog(
//                                        context: context,
//                                        builder: (BuildContext context) {
//                                          return AlertDialog(
//                                            title: Text('Invalid Count'),
//                                            content: Text('Count cannot exceed stock (${item.stock})'),
//                                            actions: <Widget>[
//                                              TextButton(
//                                                onPressed: () {
//                                                  Navigator.of(context).pop();
//                                                },
//                                                child: Text('OK'),
//                                              ),
//                                            ],
//                                          );
//                                        },
//                                      );
//                                      // Reset the TextField value to the current item count
//                                      itemControllers[item]!.text = item.count.toString();
//                                    }
//                                  }
//                                });
//                              },
//                              keyboardType: TextInputType.number,
//                              textAlign: TextAlign.center,
//                              decoration: InputDecoration(
//                                border: UnderlineInputBorder(borderSide: BorderSide.none),
//                              ),
//                            ),
//                          ),
//                          GestureDetector(
//                            child: CircleAvatar(
//                              backgroundColor: app_color,
//                              child: const Text('+', style: TextStyle(color: Colors.white)),
//                            ),
//                            onTap: () {
//                              setState(() {
//                                if (item.count < item.stock) {
//                                  item.count++;
//                                  itemControllers[item]!.text = item.count.toString();
//                                } else {
//                                  // Show an alert dialog if the count exceeds the stock
//                                  showDialog(
//                                    context: context,
//                                    builder: (BuildContext context) {
//                                      return AlertDialog(
//                                        title: Text('Invalid Count'),
//                                        content: Text('Count cannot exceed stock (${item.stock})'),
//                                        actions: <Widget>[
//                                          TextButton(
//                                            onPressed: () {
//                                              Navigator.of(context).pop();
//                                            },
//                                            child: Text('OK'),
//                                          ),
//                                        ],
//                                      );
//                                    },
//                                  );
//                                }
//                              });
//                            },
//                          ),
//                        ],
//                      )
//                    ],
//                  ),
//                ),
//              ),
//              Divider(thickness: 2, color: app_color.withOpacity(.2),),
//            ],
//          );
//        },
//      ),
//    ),