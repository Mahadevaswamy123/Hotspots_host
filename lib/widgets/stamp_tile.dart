import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StampTile extends StatelessWidget {
  final String iconUrl;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const StampTile({
    super.key,
    required this.iconUrl,
    required this.label,
    required this.selected,
    required this.onTap,
    required String imageUrl,
    required String title,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withOpacity(0.18)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? Colors.white.withOpacity(0.6)
              : Colors.white.withOpacity(0.14),
          width: selected ? 1.8 : 1.1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: iconUrl,
              width: 30,
              height: 30,
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.image_not_supported_outlined, size: 28),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
