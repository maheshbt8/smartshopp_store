import 'package:delivery_owner/config/api.dart';
import 'package:delivery_owner/model/server/category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';
import '../util.dart';

foodsLoad(String uid,
    Function(List<ImageData>, List<FoodsData>, List<RestaurantData>, List<ExtrasGroupData>, List<NutritionGroupData>, int numberOfDigits) callback,
    Function(String) callbackError) async {

  var url = '${serverPath}foodsList';
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
      if (jsonResult["error"] != "0")
        return callbackError(jsonResult["error"]);
      ResponseFoods ret = ResponseFoods.fromJson(jsonResult);
      callback(ret.images, ret.foods, ret.restaurants, ret.extrasGroupData, ret.nutritionGroupData, ret.numberOfDigits);
    }else
      callbackError("statusCode=${response.statusCode}");
  } catch (ex) {
    callbackError(ex.toString());
  }
}

class ResponseFoods {
  String error;
  String id;
  List<ImageData> images;
  List<FoodsData> foods;
  List<RestaurantData> restaurants;
  List<ExtrasGroupData> extrasGroupData;
  List<NutritionGroupData> nutritionGroupData;
  int numberOfDigits;

  ResponseFoods({this.error, this.images, this.foods, this.id,
    this.restaurants, this.extrasGroupData, this.nutritionGroupData, this.numberOfDigits});

  factory ResponseFoods.fromJson(Map<String, dynamic> json){

    var t = json['foods'].map((f) => FoodsData.fromJson(f)).toList();
    var _foods = t.cast<FoodsData>().toList();

    t = json['images'].map((f) => ImageData.fromJson(f)).toList();
    var _images = t.cast<ImageData>().toList();

    t = json['restaurants'].map((f) => RestaurantData.fromJson(f)).toList();
    var _restaurants = t.cast<RestaurantData>().toList();

    var _extrasGroupData;
    if (json['extrasGroup'] != null) {
      t = json['extrasGroup'].map((f) => ExtrasGroupData.fromJson(f)).toList();
      _extrasGroupData = t.cast<ExtrasGroupData>().toList();
    }

    var _nutritionGroupData;
    if (json['nutritionGroup'] != null){
      t = json['nutritionGroup'].map((f) => NutritionGroupData.fromJson(f)).toList();
      _nutritionGroupData = t.cast<NutritionGroupData>().toList();
    }

    return ResponseFoods(
      error: json['error'].toString(),
      id: json['id'].toString(),
      images: _images,
      foods: _foods,
      restaurants: _restaurants,
      extrasGroupData: _extrasGroupData,
      nutritionGroupData: _nutritionGroupData,
      numberOfDigits: toInt(json['numberOfDigits'].toString()),
    );
  }
}

class FoodsData {
  String id;
  String updatedAt;
  String name;
  int imageid;
  String price;
  String discountprice;
  String desc;
  int restaurant;
  int category;
  String ingredients;
  String visible;
  int extras;
  int nutrition;
  List<String> imagesFilesIds;
  List<VariantsData> variants;

  FoodsData({this.id, this.name, this.updatedAt, this.desc, this.imageid, this.price,
    this.ingredients, this.visible, this.extras, this.nutrition,
    this.restaurant, this.category, this.discountprice, this.imagesFilesIds, this.variants
  });
  factory FoodsData.fromJson(Map<String, dynamic> json) {
    List<String> _imagesFilesIds = [];
    if (json['images'] != null)
      _imagesFilesIds = json['images'].toString().split(',');

    var t = json['variants'].map((f) => VariantsData.fromJson(f)).toList();
    var _variants = t.cast<VariantsData>().toList();

    return FoodsData(
      id : json['id'].toString(),
      updatedAt : json['updated_at'].toString(),
      name: json['name'].toString(),
      imageid: toInt(json['imageid'].toString()),
      price : json['price'].toString(),
      discountprice : json['discountprice'].toString(),
      desc : json['desc'].toString(),
      ingredients : json['ingredients'].toString(),
      visible : json['published'].toString(),
      extras : toInt(json['extras'].toString()),
      nutrition : toInt(json['nutritions'].toString()),
      restaurant : toInt(json['restaurant'].toString()),
      category : toInt(json['category'].toString()),
      imagesFilesIds: _imagesFilesIds,
      variants: _variants
    );
  }
}

class VariantsData {
  int id;
  String name;
  int imageId;
  double price;
  double dprice;

  VariantsData({this.id, this.name, this.imageId, this.price, this.dprice});
  factory VariantsData.fromJson(Map<String, dynamic> json) {
    return VariantsData(
      id : toInt(json['id'].toString()),
      name: json['name'].toString(),
      imageId: toInt(json['imageid'].toString()),
      price : toDouble(json['price'].toString()),
      dprice : toDouble(json['dprice'].toString()),
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "id": this.id,
      "name": this.name,
      "imageid": this.imageId,
      "price": this.price,
      "dprice": this.dprice,
    };
  }
}

class RestaurantData {
  int id;
  String updatedAt;
  String name;
  String imageId;
  String published;

  RestaurantData({this.id, this.name, this.updatedAt, this.imageId, this.published});
  factory RestaurantData.fromJson(Map<String, dynamic> json) {
    return RestaurantData(
      id : toInt(json['id'].toString()),
      updatedAt : json['updatedAt'].toString(),
      name: json['name'].toString(),
      imageId: json['imageId'].toString(),
      published : json['published'].toString(),
    );
  }
}


class ExtrasGroupData {
  int id;
  String updatedAt;
  String name;
  int restaurant;

  ExtrasGroupData({this.id, this.name, this.updatedAt, this.restaurant});
  factory ExtrasGroupData.fromJson(Map<String, dynamic> json) {
    return ExtrasGroupData(
      id : toInt(json['id'].toString()),
      updatedAt : json['updated_at'].toString(),
      name: json['name'].toString(),
      restaurant: toInt(json['restaurant'].toString()),
    );
  }
}

class NutritionGroupData {
  int id;
  String updatedAt;
  String name;

  NutritionGroupData({this.id, this.name, this.updatedAt});
  factory NutritionGroupData.fromJson(Map<String, dynamic> json) {
    return NutritionGroupData(
      id : toInt(json['id'].toString()),
      updatedAt : json['updatedAt'].toString(),
      name: json['name'].toString(),
    );
  }
}
