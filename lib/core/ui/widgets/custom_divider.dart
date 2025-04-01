import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final Color color;
  const CustomDivider({super.key, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.2,
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              Colors.transparent,
              color,
              color,
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ).createShader(bounds);
        },
        child: Container(
          color: color,
        ),
      ),
    );
  }
}
