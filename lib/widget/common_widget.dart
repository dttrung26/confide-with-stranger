import 'package:flutter/material.dart';

AppBar appBarMain(
    {String? title, BuildContext? context, List<Widget>? actions}) {
  return AppBar(
    backgroundColor: Colors.blueGrey,
    title: Text(title ?? ""),
    actions: actions,
  );
}

InputDecoration textFieldInputDecoration(String textHint) {
  return InputDecoration(
    hintText: textHint,
    hintStyle: const TextStyle(color: Colors.grey),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blueGrey),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.lightBlueAccent),
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    context, String message) {
  SnackBar snackBar = SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
  );
  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
