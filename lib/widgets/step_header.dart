import 'package:flutter/material.dart';

class StepHeader extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback onClose;

  const StepHeader({
    super.key,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Step $step of $total',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
