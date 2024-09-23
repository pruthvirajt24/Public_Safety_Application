import 'package:flutter/material.dart';

class HSpace extends StatelessWidget {
  final double size;
  const HSpace({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
    );
  }
}
