import 'dart:typed_data';

import 'package:delivery_owner/ui/main/home.dart';
import 'package:image/image.dart';

double toDouble(String str){
  double ret = 0;
  try {
    ret = double.parse(str);
  }catch(_){}
  return ret;
}

String makePrice(double _price){
  if (totals.rightSymbol == "true")
    return "${_price.toStringAsFixed(totals.symbolDigits)}${totals.code}";
  else
    return "${totals.code}${_price.toStringAsFixed(totals.symbolDigits)}";
}

resizeImage(Uint8List data, int width){
  Image image = decodeImage(data);
  Image thumbnail;
  if (image.width < image.height)
    thumbnail = copyResize(image, width: width);
  else
    thumbnail = copyResize(image, height: width);
  return encodePng(thumbnail);
}