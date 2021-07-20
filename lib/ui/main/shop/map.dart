import 'package:delivery_owner/main.dart';
import 'package:delivery_owner/ui/widgets/iboxCircle.dart';
import 'package:flutter/material.dart';

buttonMyLocation(Function() _getCurrentLocation){
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

mapButtonBack(Function() _backButtonPress){
  return Stack(
    children: <Widget>[
      Container(
        height: 60,
        width: 60,
        child: IBoxCircle(child: Center(child: Text(strings.get(178), style: theme.text14bold,))),
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
                _backButtonPress();
              }, // needed
            )),
      )
    ],
  );
}