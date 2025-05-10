import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
  final Function()? onPressed;

  const MyFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.black,
      shape:RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Custom border radius
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
