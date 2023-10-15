import 'package:flutter/material.dart';

class ItemPriceData extends StatefulWidget {
  const ItemPriceData({super.key, this.data,});
final data;
  @override
  State<ItemPriceData> createState() => _ItemPriceDataState();
}

class _ItemPriceDataState extends State<ItemPriceData> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('data'),
          ListView.builder(
              itemBuilder:widget.data,
            itemCount: widget.data.length,


          )
        ],
      ),
    );
  }
}
