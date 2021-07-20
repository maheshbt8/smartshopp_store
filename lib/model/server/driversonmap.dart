import 'package:delivery_owner/config/api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';
import '../util.dart';

driversOnMapLoad(String uid, Function(List<DriverOnMapItem> driversOnMap, List<DriverOnMapItem> shopsOnMap) callback, Function(String) callbackError) async {

  var url = '${serverPath}driversOnMapList';
  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': "application/json",
    'Authorization' : "Bearer $uid",
  };
  var body = json.encoder.convert({
  });
  try {
    var response = await http.post(url, headers: requestHeaders, body: body).timeout(const Duration(seconds: 30));
    dprint('Response status: ${response.statusCode}');
    dprint('Response body: ${response.body}');
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      var ret = DriverOnMap.fromJson(jsonResult);
      callback(ret.list, ret.shops);
    }else
      callbackError("statusCode=${response.statusCode}");
  } catch (ex) {
    callbackError(ex.toString());
  }
}

class DriverOnMap {
  String error;
  List<DriverOnMapItem> list;
  List<DriverOnMapItem> shops;
  DriverOnMap({this.error, this.list, this.shops});
  factory DriverOnMap.fromJson(Map<String, dynamic> json){

    var t = json['list'].map((f) => DriverOnMapItem.fromJson(f)).toList();
    var _list = t.cast<DriverOnMapItem>().toList();

    var t2 = json['shops'].map((f) => DriverOnMapItem.fromJson(f)).toList();
    var _shops = t2.cast<DriverOnMapItem>().toList();

    return DriverOnMap(
      error: json['error'].toString(),
      list: _list,
      shops: _shops
    );
  }
}

class DriverOnMapItem {
  String id;
  String name;
  String image;
  double lat;
  double lng;
  // Image png;
  bool visible;

  // group
  bool group;
  double lat2;
  double lng2;
  int count;
  Marker marker;
  Marker marker2;

  DriverOnMapItem({this.id, this.name, this.image, this.lat, this.lng, this.visible = true,
        this.group = false, this.lat2, this.lng2, this.count = 0, this.marker, this.marker2});
  factory DriverOnMapItem.fromJson(Map<String, dynamic> json){
    return DriverOnMapItem(
      id: json['id'].toString(),
      name: json['name'].toString(),
      image: json['image'].toString(),
      lat: (json['lat'] == null) ? 0 : toDouble(json['lat'].toString()),
      lng: (json['lng'] == null) ? 0 : toDouble(json['lng'].toString())
    );
  }
}
