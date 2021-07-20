import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:delivery_owner/ui/widgets/iboxCircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

markerNumber(String id, int count, double lat, double lng) async {
  var size = 150.0;

  PictureRecorder recorder = new PictureRecorder();
  Canvas canvas = new Canvas(recorder);

  final center = Offset(size/2, size/2);
  final double radius = size/2;

  Paint paintCircle = Paint()..color = Colors.white;
  Paint paintBorder = Paint()
    ..color = Colors.lightBlueAccent
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  canvas.drawCircle(center, radius, paintCircle);
  canvas.drawCircle(center, radius, paintBorder);

  // text
  final _textPainter = TextPainter(textDirection: TextDirection.ltr);
  final TextStyle textStyle = TextStyle(fontSize: 100, color: Colors.lightBlueAccent, fontWeight: FontWeight.w800);

  _textPainter.text = TextSpan(text: "$count", style: textStyle);
  _textPainter.layout(
    minWidth: 0,
    maxWidth: double.maxFinite,
  );
  // dprint("_textPainter.width ${_textPainter.width}");
  _textPainter.paint(canvas, Offset((size-_textPainter.width)/2, (size-_textPainter.height)/2));


  Picture p = recorder.endRecording();
  var t = await p.toImage(size.toInt(), size.toInt());
  ByteData r = await t.toByteData(format: ImageByteFormat.png);
  //item.png = Image.memory(r.buffer.asUint8List());
  var myIcon = BitmapDescriptor.fromBytes(r.buffer.asUint8List());

  //dprint("_addMarkerNumber id = ${item.id} item.lat=${item.lat} item.lng=${item.lng}");

  var _lastMarkerId2 = MarkerId(id);
  final marker = Marker(
      markerId: _lastMarkerId2,
      zIndex: 20,
      position: LatLng(
          lat, lng
      ),
      // infoWindow: InfoWindow(
      //   title: "Marker 2",
      //   snippet: "text",
      //   onTap: () {
      //     print("tap on marker");
      //   },
      // ),
      onTap: () {

      },
      icon: myIcon
  );
  return marker;
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
}

markerSimple(String id, double lat, double lng) async {
  var size = 50;
  var recorder = new PictureRecorder();
  var canvas = new Canvas(recorder);
  var center = Offset(size/2, size/2);
  var radius = size/2;
  var paintCircle = Paint()..color = Colors.lightBlueAccent;
  canvas.drawCircle(center, radius, paintCircle);
  var p = recorder.endRecording();
  var t = await p.toImage(size.toInt(), size.toInt());
  var r = await t.toByteData(format: ImageByteFormat.png);
  //item.png = Image.memory(r.buffer.asUint8List());
  var myIcon2 = BitmapDescriptor.fromBytes(r.buffer.asUint8List());
  var _lastMarkerId2 = MarkerId(id);
  final marker2 = Marker(
      markerId: _lastMarkerId2,
      zIndex: 10,
      position: LatLng(
          lat, lng
      ),
      // infoWindow: InfoWindow(
      //   title: "Marker 2",
      //   snippet: "text",
      //   onTap: () {
      //     print("tap on marker");
      //   },
      // ),
      onTap: () {

      },
      icon: myIcon2
  );
  return marker2;
}

markerImage(Uint8List _resizeSrc, String id, double lat, double lng, String name) async {
  // var url = "$serverImages${item.image}";
  // dprint("get $url}");
  // var response = await http.get(url);
  // var image = Image.memory(response.bodyBytes);
  // item.png = image;
  var size = 150.0;
  // var _resizeSrc = resizeImage(_iconDriver, (size*0.7).toInt());

  //var _resizeSrc = resizeImage(response.bodyBytes.buffer.asUint8List(), (size*0.7).toInt());
  ui.Codec codec = await ui.instantiateImageCodec(_resizeSrc);
  ui.FrameInfo fi = await codec.getNextFrame();
  ui.Image srcimage = fi.image;

  PictureRecorder recorder = new PictureRecorder();
  Canvas canvas = new Canvas(recorder);

  var center = Offset(size/2, size/2);
  double radius = size/2;

  Paint paintCircle = Paint()..color = Colors.white;
  Paint paintBorder = Paint()
    ..color = Colors.lightBlueAccent
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  canvas.drawCircle(center, radius, paintCircle);
  canvas.drawCircle(center, radius, paintBorder);

  canvas.save();
  Path path = Path()
    ..addOval(Rect.fromLTWH(size*0.2, size*0.2, size*0.6, size*0.6));
  canvas.clipPath(path);

  if (srcimage.width <= srcimage.height)
    canvas.drawImage(srcimage, Offset(size*0.15, size*0.15), Paint());
  else
    canvas.drawImage(srcimage, Offset(0, size*0.15), Paint());

  canvas.restore();

  // text
  canvas.translate(size / 2, - size*0.15);

  var initialAngle = -45.0;
  if (initialAngle != 0) {
    final d = 2 * size*0.65 * math.sin(initialAngle / 2);
    final rotationAngle = _calculateRotationAngle(0, initialAngle);
    canvas.rotate(rotationAngle);
    canvas.translate(d, 0);
  }

  double angle = initialAngle;
  for (int i = 0; i < name.length; i++) {
    angle =  _drawLetter(canvas, name[i], angle, size*0.65);
  }
  // end text

  Picture p = recorder.endRecording();
  var t = await p.toImage(size.toInt(), size.toInt());
  ByteData r = await t.toByteData(format: ImageByteFormat.png);
  // item.png = Image.memory(r.buffer.asUint8List());
  var myIcon = BitmapDescriptor.fromBytes(r.buffer.asUint8List());

  // myIcon = BitmapDescriptor.fromBytes(_resizeSrc);

  // Bitmap bitmap = Bitmap.fromHeadless(100, 100, r.buffer.asUint8List());
  // Uint8List headedIntList = bitmap.buildHeaded();
  // item.png = Image.memory(headedIntList);
  // item.png = await t.toByteData(format: ImageByteFormat.png);

  var _lastMarkerId2 = MarkerId(id);
  final marker = Marker(
      markerId: _lastMarkerId2,
      zIndex: 20,
      position: LatLng(
          lat, lng
      ),
      // infoWindow: InfoWindow(
      //   title: "Marker 2",
      //   snippet: "text",
      //   onTap: () {
      //     print("tap on marker");
      //   },
      // ),
      onTap: () {

      },
      icon: myIcon
  );

  return marker;
}

double _calculateRotationAngle(double prevAngle, double alpha) => (alpha + prevAngle) / 2;

final _textPainter = TextPainter(textDirection: TextDirection.ltr);
final TextStyle textStyle = TextStyle(fontSize: 20, letterSpacing: 20, color: Colors.black,);

double _drawLetter(Canvas canvas, String letter, double prevAngle, double radius) {
  _textPainter.text = TextSpan(text: letter, style: textStyle);
  _textPainter.layout(
    minWidth: 0,
    maxWidth: double.maxFinite,
  );

  final double d = _textPainter.width;
  final double alpha = 2 * math.asin(d / (2 * radius));

  final newAngle = _calculateRotationAngle(prevAngle, alpha);
  canvas.rotate(newAngle);

  _textPainter.paint(canvas, Offset(0, _textPainter.height));
  canvas.translate(d, 0);

  return alpha;
}

buttonPlus(Function callback){
  return Stack(
    children: <Widget>[
      Container(
        height: 60,
        width: 60,
        child: IBoxCircle(child: Icon(Icons.add, size: 30, color: Colors.black,)),
      ),
      Container(
        height: 60,
        width: 60,
        child: Material(
            color: Colors.transparent,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.grey[400],
              onTap: callback, // needed
            )),
      )
    ],
  );
}

buttonMinus(Function _onMapMinus){
  return Stack(
    children: <Widget>[
      Container(
        height: 60,
        width: 60,
        child: IBoxCircle(child: Icon(Icons.remove, size: 30, color: Colors.black,)),
      ),
      Container(
        height: 60,
        width: 60,
        child: Material(
            color: Colors.transparent,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.grey[400],
              onTap: _onMapMinus, // needed
            )),
      )
    ],
  );
}

buttonMyLocation(Function _getCurrentLocation){
  return Stack(
    children: <Widget>[
      Container(
        height: 60,
        width: 60,
        child: IBoxCircle(child: Icon(Icons.my_location, size: 30, color: Colors.black.withOpacity(0.5),)),
      ),
      Container(
        height: 60,
        width: 60,
        child: Material(
            color: Colors.transparent,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.grey[400],
              onTap: (){
                _getCurrentLocation();
              }, // needed
            )),
      )
    ],
  );
}