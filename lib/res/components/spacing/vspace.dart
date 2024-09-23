import 'package:flutter/material.dart';

class Vspace extends StatelessWidget {
  final double size;
  const Vspace({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
    );
  }
}
