import 'package:flutter/material.dart';

/// Widget untuk menampilkan logo UNHAS utuh (tanpa shadow)
class UnhasLogo extends StatelessWidget {
  final double width;
  final double height;
  final bool showText;

  const UnhasLogo({
    super.key,
    this.width = 140,
    this.height = 140,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Display full logo without shadow or clipping
        Image.asset(
          'lib/assets/icons/Logo-Resmi-Unhas-1.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.image_not_supported)),
            );
          },
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'SPARE App',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD32F2F),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Universitas Hasanuddin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ],
    );
  }
}
