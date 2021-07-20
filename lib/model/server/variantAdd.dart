import 'package:delivery_owner/config/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';

variantAdd(String productId, String name, String price, String dprice, String imageid,
    String uid, Function(int) callback, Function(String) callbackError) async {

  var url = '${serverPath}variantsAdd';
  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': "application/json",
    'Authorization' : "Bearer $uid",
  };
  var body = json.encoder.convert({
    "id" : productId,
    "name": name,
    "price" : price,
    "dprice": dprice,
    "imageid": imageid,
  });

  dprint('body: $body');
  try {
    var response = await http.post(url, headers: requestHeaders, body: body).timeout(const Duration(seconds: 30));
    dprint(url);
    dprint('Response status: ${response.statusCode}');
    dprint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult["error"] != "0")
        return callbackError(jsonResult["error"]);
      callback(toInt(jsonResult["id"].toString()));
    }else
      callbackError("statusCode=${response.statusCode}");
  } catch (ex) {
    callbackError(ex.toString());
  }
}

