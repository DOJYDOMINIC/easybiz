

import 'dart:convert';

PurchaseData purchaseDataFromJson(String str) => PurchaseData.fromJson(json.decode(str));

String purchaseDataToJson(PurchaseData data) => json.encode(data.toJson());

class PurchaseData {
  String compCode;
  String ordDate;
  String ordTime;
  String itemCode;
  String itemName;
  String itemQty;
  String itemPrice;
  String itemTax;
  String itemDisc;
  String itemCess;
  String trxTotal;
  String statusFlag;
  String actCode;
  String actName;
  String actAddress;
  String actPhone;
  String actArea;
  String actType;
  String trxDisc;
  String trxNetamount;
  String userCode;
  String userName;
  String latLong;
  String systemName;

  PurchaseData({
    required this.compCode,
    required this.ordDate,
    required this.ordTime,
    required this.itemCode,
    required this.itemName,
    required this.itemQty,
    required this.itemPrice,
    required this.itemTax,
    required this.itemDisc,
    required this.itemCess,
    required this.trxTotal,
    required this.statusFlag,
    required this.actCode,
    required this.actName,
    required this.actAddress,
    required this.actPhone,
    required this.actArea,
    required this.actType,
    required this.trxDisc,
    required this.trxNetamount,
    required this.userCode,
    required this.userName,
    required this.latLong,
    required this.systemName,
  });

  factory PurchaseData.fromJson(Map<String, dynamic> json) => PurchaseData(
    compCode: json["comp_code"],
    ordDate: json["ord_date"],
    ordTime: json["ord_time"],
    itemCode: json["item_code"],
    itemName: json["item_name"],
    itemQty: json["item_qty"],
    itemPrice: json["item_price"],
    itemTax: json["item_tax"],
    itemDisc: json["item_disc"],
    itemCess: json["item_cess"],
    trxTotal: json["trx_total"],
    statusFlag: json["status_flag"],
    actCode: json["act_code"],
    actName: json["act_name"],
    actAddress: json["act_address"],
    actPhone: json["act_phone"],
    actArea: json["act_area"],
    actType: json["act_type"],
    trxDisc: json["trx_disc"],
    trxNetamount: json["trx_netamount"],
    userCode: json["user_code"],
    userName: json["user_name"],
    latLong: json["lat_long"],
    systemName: json["system_name"],
  );

  Map<String, dynamic> toJson() => {
    "comp_code": compCode,
    "ord_date": ordDate,
    "ord_time": ordTime,
    "item_code": itemCode,
    "item_name": itemName,
    "item_qty": itemQty,
    "item_price": itemPrice,
    "item_tax": itemTax,
    "item_disc": itemDisc,
    "item_cess": itemCess,
    "trx_total": trxTotal,
    "status_flag": statusFlag,
    "act_code": actCode,
    "act_name": actName,
    "act_address": actAddress,
    "act_phone": actPhone,
    "act_area": actArea,
    "act_type": actType,
    "trx_disc": trxDisc,
    "trx_netamount": trxNetamount,
    "user_code": userCode,
    "user_name": userName,
    "lat_long": latLong,
    "system_name": systemName,
  };
}
