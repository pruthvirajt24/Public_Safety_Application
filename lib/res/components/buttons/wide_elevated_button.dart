import 'package:flutter/material.dart';

class WideElevatedButton extends StatelessWidget {
  const WideElevatedButton({
    super.key,
    required this.size,
    required this.onCLick,
    required this.label,
    required this.primary,
  });

  final Size size;
  final VoidCallback onCLick;
  final String label;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.07,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onCLick,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: size.height * 0.025, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
