import 'package:flutter/material.dart';

double fullWidth(BuildContext context) {
  // cprint(MediaQuery.of(context).size.width.toString());
  return MediaQuery.of(context).size.width;
}

double fullHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

void customSnackBar(
  GlobalKey<ScaffoldState> _scaffoldKey,
  String msg, {
  double height = 30,
  Color backgroundColor = Colors.white,
}) {
  if (_scaffoldKey == null || _scaffoldKey.currentState == null) {
    return;
  }
  _scaffoldKey.currentState.hideCurrentSnackBar();
  final snackBar = SnackBar(
    backgroundColor: backgroundColor,
    content: Text(
      msg,
      style: TextStyle(
        color: Colors.black,
      ),
    ),
  );
  _scaffoldKey.currentState.showSnackBar(snackBar);
}
