import 'package:flutter/material.dart';

class BloodCard extends StatelessWidget {
  final String group;
  final String bags;
  final int count;

  const BloodCard({
    super.key,
    required this.group,
    required this.bags,
    this.count = 0,
  });

  Color get _cardColor {
    if (count == 0) return const Color(0xFFFFEBEE);
    if (count <= 2) return const Color(0xFFFFF3E0);
    return const Color(0xFFFFEBEE);
  }

  Color get _textColor {
    if (count == 0) return const Color(0xFFB71C1C);
    if (count <= 2) return const Color(0xFFF57C00);
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bloodtype, color: _textColor, size: 32),
          const SizedBox(height: 8),
          Text(
            group,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bags,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _textColor.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}