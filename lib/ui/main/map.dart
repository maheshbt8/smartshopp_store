import 'dart:ui';
import 'package:delivery_owner/main.dart';
import 'package:delivery_owner/model/geolocator.dart';
import 'package:delivery_owner/model/map.dart';
import 'package:delivery_owner/model/pref.dart';
import 'package:delivery_owner/model/server/driversonmap.dart';
import 'package:delivery_owner/model/util.dart';
import 'package:delivery_owner/ui/widgets/appbar1.dart';
import 'package:delivery_owner/ui/widgets/colorloader2.dart';
import 'package:delivery_owner/ui/widgets/easyDialog2.dart';
import 'package:delivery_owner/ui/widgets/ibutton3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPageScreen extends StatefulWidget {
  @override
  _MapPageScreenState createState() => _MapPageScreenState();
}

class _MapPageScreenState extends State<MapPageScreen> {

  var windowWidth;
  var windowHeight;

  CameraPosition _kGooglePlex = CameraPosition(target: LatLng(defLat, defLng), zoom: 12,); // paris coordinates
  Set<Marker> markers = {};
  GoogleMapController _controller;
  double _currentZoom = 12;

  @override
  void initState() {
    _waits(true);
    _initIcons();
    driversOnMapLoad(account.token, _success, _error);

    var _lat = toDouble(pref.get(Pref.driverMapLat));
    var _lng = toDouble(pref.get(Pref.driverMapLng));
    var _zoom = toDouble(pref.get(Pref.driverMapZoom));
    if (_zoom != 0) {
      _currentZoom = _zoom;
      _kGooglePlex = CameraPosition(target: LatLng(_lat, _lng), zoom: _zoom,);
    }

    super.initState();
  }

  var _iconDriver;
  var _iconShop;

  _initIcons() async {
    _iconDriver = await getBytesFromAsset('assets/icondriver.png', 200);
    _iconDriver = resizeImage(_iconDriver, (150*0.7).toInt());
    _iconShop = await getBytesFromAsset('assets/iconshop.png', 200);
    _iconShop = resizeImage(_iconShop, (150*0.7).toInt());
  }

  List<DriverOnMapItem> _driversOnMap;
  List<DriverOnMapItem> _groupOnMap = [];

  _success(List<DriverOnMapItem> driversOnMap, List<DriverOnMapItem> shopsOnMap) async {
    _waits(false);
    _driversOnMap = driversOnMap;
    _driversOnMap.addAll(shopsOnMap);
    for (var item in driversOnMap)
      await _addMarker(item, 1);

    for (var item in shopsOnMap)
      await _addMarker(item, 2);

    await _getVisibleRegion(_currentZoom);
    // dprint("_success complete");
    setState(() {});
  }

  _addMarker(DriverOnMapItem item, int type) async {
    if (item.lat == 0 && item.lng == 0)
      return;

    var _resizeSrc = _iconDriver;
    if (type == 2)
      _resizeSrc = _iconShop;

    //
    // Marker
    //
    item.marker = await markerImage(_resizeSrc, item.id, item.lat, item.lng, item.name);

    //
    // Marker2
    //
    item.marker2 = await markerSimple(item.id, item.lat, item.lng);
  }

  _error(String error){
    _waits(false);
    openDialog("${strings.get(158)} $error"); // "Something went wrong. ",
  }

  bool _wait = false;

  _waits(bool value){
    _wait = value;
    if (mounted)
      setState(() {
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
          children: <Widget>[

            _map(),
            //_getMarkers(),

            Container(
              width: windowWidth,
              height: windowHeight,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 15,),
                        buttonPlus(_onMapPlus),
                        buttonMinus(_onMapMinus),
                        buttonMyLocation(_getCurrentLocation),
                      ],
                    )
                ),
              ),
            ),

            appbar1(Colors.white, Colors.black, strings.get(258), context, () {Navigator.pop(context);}), // Drivers on Map

            if (_wait)
              Container(
                color: Color(0x80000000),
                width: windowWidth,
                height: windowHeight,
                child: Center(
                  child: ColorLoader2(
                    color1: theme.colorPrimary,
                    color2: theme.colorCompanion,
                    color3: theme.colorPrimary,
                  ),
                ),
              ),

            IEasyDialog2(setPosition: (double value){_show = value;}, getPosition: () {return _show;}, color: theme.colorGrey,
                body: _dialogBody, backgroundColor: theme.colorBackground),

          ],
        )
    );
  }

  double _show = 0;
  Widget _dialogBody = Container();

  openDialog(String _text) {
    _dialogBody = Column(
      children: [
        Text(_text, style: theme.text14,),
        SizedBox(height: 40,),
        IButton3(
            color: theme.colorPrimary,
            text: strings.get(66),              // Cancel
            textStyle: theme.text14boldWhite,
            pressButton: (){
              setState(() {
                _show = 0;
              });
            }
        ),
      ],
    );

    setState(() {
      _show = 1;
    });
  }

  _map(){
    return GoogleMap(
        mapType: MapType.normal,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false, // Whether to show zoom controls (only applicable for Android).
        myLocationEnabled: true,  // For showing your current location on the map with a blue dot.
        myLocationButtonEnabled: false, // This button is used to bring the user location to the center of the camera view.
        initialCameraPosition: _kGooglePlex,
        onTap: (LatLng pos) {

        },
        onLongPress: (LatLng pos) {

        },
        markers: markers != null ? Set<Marker>.from(markers) : null,
        onCameraMove: (CameraPosition position){
          pref.set(Pref.driverMapLat, position.target.latitude.toString());
          pref.set(Pref.driverMapLng, position.target.longitude.toString());
          pref.set(Pref.driverMapZoom, position.zoom.toString());
          _getVisibleRegion(position.zoom);

          //dprint("--set state");
          setState(() {
          });
        },
        onMapCreated: (GoogleMapController controller) {
         _controller = controller;
        });

  }

  _onMapPlus(){
    _controller?.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  _onMapMinus(){
    _controller?.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  Location location = Location();

  _getCurrentLocation() async {
    var position = await location.getCurrent();
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12,
        ),
      ),
    );
  }

  var lastZoom;
  _getVisibleRegion(double zoom) async {
    if (lastZoom == zoom)
      return;
    lastZoom = zoom;

    LatLngBounds bound = await _controller.getVisibleRegion();
    // dprint("-------------------------------");
    // dprint("bound.northeast=${bound.northeast} bound.southwest=${bound.southwest}");
    var s = bound.northeast.latitude-bound.southwest.latitude;
    var t = windowHeight/20;
    // dprint("с севера на юг=$s windowHeight=$windowHeight windowHeight/60=${windowHeight/30}");
    var n = s/t;
    // dprint("n=$n");
    _groupOnMap.clear();
    for (var item in _driversOnMap)
      item.visible = true;
    for (var item in _driversOnMap){
      if (item.lat == 0 && item.lng == 0) {
        item.visible = false;
        continue;
      }

      // if (!bound.contains(LatLng(item.lat, item.lng)))
      //   continue;
      //dprint("item=${item.name} ${item.lat} ${item.lng}");

      for (var item2 in _driversOnMap) {
        if (item.id == item2.id)
          continue;
        // if (!bound.contains(LatLng(item2.lat, item2.lng)))
        //   continue;
        if (item.lat > item2.lat)
          if (item.lat - n < item2.lat) {

            if (item.lng >= item2.lng) {
              if (item.lng - n <= item2.lng) {
                item.visible = false;
                // item2.visible = false;
              }
            }else
              if (item.lng + n >= item2.lng) {
                item.visible = false;
                // item2.visible = false;
              }

          }

        if (item.lat == item2.lat) {
          if (item.lng >= item2.lng)
            if (item.lng - n <= item2.lng) {
              item.visible = false;
              // item2.visible = false;
            }
        }

        if (item.lat < item2.lat)
          if (item.lat + n > item2.lat) {

            if (item.lng >= item2.lng) {
              if (item.lng - n <= item2.lng) {
                item.visible = false;
                // item2.visible = false;
              }
            }else
              if (item.lng + n >= item2.lng) {
                item.visible = false;
                // item2.visible = false;
              }
          }

        // if (item.name == "Robertos")
        //   dprint("${item.name} visible=${item.visible} ");

      }
    }
    markers = {};



    for (var item in _driversOnMap){
      if (item.lat == 0 && item.lng == 0)
        continue;
      // dprint("markers = $markers");
      // dprint("markers add= ${item.marker}");
      // markers.forEach((element) {
      //   dprint("markers forEach = $element");
      // });
      if (!item.visible) {
        var found = false;
        for (var item2 in _groupOnMap)
          if (_itemInN(item, item2, n)) {
            found = true;
            item2.count++;
          }
          if (!found)
            _groupOnMap.add(
                DriverOnMapItem(
                    id: UniqueKey().toString(),
                    group: true,
                    lat: item.lat,
                    lat2: item.lat + n,
                    lng: item.lng,
                    lng2: item.lng + n,
                    count: 1
            ));
      }else{
        if (item.marker != null)
          markers.add(item.marker);
      }
    }

    for (var item in _groupOnMap){
      var titem = _inGroupCache(item);
      if (titem == null)
        await _addMarkerNumber(item);
      else
        item.marker = titem.marker;

      _addToGroupCache(item);
      markers.add(item.marker);
      //dprint("add group market ${item.count}");
    }

    for (var item in _driversOnMap) {
      if (item.lat == 0 && item.lng == 0)
        continue;
      if (!item.visible)
        if (item.marker2 != null)
          markers.add(item.marker2);
    }

    //dprint("-------------------------------");
  }

  _inGroupCache(DriverOnMapItem item){
    for (var gitem in groupCache)
      if (gitem.lat == item.lat &&
          gitem.lng == item.lng &&
          gitem.count == item.count)
        return gitem;
      return null;
  }

  _addToGroupCache(DriverOnMapItem item){
    for (var gitem in groupCache)
      if (gitem.lat == item.lat &&
          gitem.lng == item.lng &&
          gitem.count == item.count)
        return;
      groupCache.add(item);
  }

  List<DriverOnMapItem> groupCache = [];

  _itemInN(DriverOnMapItem item, DriverOnMapItem group, double n){
    if (item.lat+n >= group.lat && item.lat-n <= group.lat2)
      if (item.lng+n >= group.lng && item.lng-n <= group.lng2)
        return true;
    return false;
  }

  _addMarkerNumber(DriverOnMapItem item) async {
    item.marker = await markerNumber(item.id, item.count, item.lat, item.lng);
  }

}

