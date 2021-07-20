import 'package:delivery_owner/config/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';

chatUsers(String uid, Function(List<ChatUsers>) callback, Function(String) callbackError) async {

    try {
      var url = "${serverPath}chatUsers";
      var response = await http.get(url, headers: {
          'Authorization': 'Bearer $uid',
      }).timeout(const Duration(seconds: 30));

      dprint("api/chatUsers");
      dprint('Response status: ${response.statusCode}');
      dprint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        if (jsonResult['error'] == '0') {
          Response ret = Response.fromJson(jsonResult);
          callback(ret.users);
        }else
          callbackError("error=${jsonResult['error']}");
      } else
        callbackError("statusCode=${response.statusCode}");
    } catch (ex) {
      callbackError(ex.toString());
    }
  }


class Response {
  String error;
  List<ChatUsers> users;
  Response({this.error, this.users});
  factory Response.fromJson(Map<String, dynamic> json){
    var m;
    if (json['users'] != null) {
      var items = json['users'];
      var t = items.map((f)=> ChatUsers.fromJson(f)).toList();
      m = t.cast<ChatUsers>().toList();
    }
    return Response(
      error: json['error'].toString(),
      users: m,
    );
  }
}

class ChatUsers {
  String id;
  String name;
  String image;
  String count;
  int unread;

  ChatUsers({this.id, this.name, this.image, this.count, this.unread});
  factory ChatUsers.fromJson(Map<String, dynamic> json){
    var _count;
    if (json['count'] == null)
      _count = json['messages'].toString();
    else
      _count = json['count'].toString();

    return ChatUsers(
      id: json['id'].toString(),
      name: json['name'].toString(),
      image: json['image'].toString(),
      count: _count,
      unread: toInt(json['unread'].toString()),
    );
  }

  int compareTo(ChatUsers b){
    if (unread > b.unread)
      return -1;
    if (unread < b.unread)
      return 1;
    return 0;
  }
}
