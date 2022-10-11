import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String title;
  VoidCallback onPressed;

  MyButton({Key? key, required this.title, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Theme.of(context).primaryColor,
      onPressed: onPressed,
      child: Text(title),
    );
  }
}
