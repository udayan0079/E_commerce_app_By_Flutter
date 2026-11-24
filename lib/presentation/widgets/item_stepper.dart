import 'package:flutter/material.dart';
import '../../app/app_colors.dart';

/// Quantity Stepper (- [count] +) widget for Cart and Product Details.
class ItemStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;
  final Color backgroundColor;
  final Color iconColor;

  const ItemStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 99,
    this.backgroundColor = AppColors.primaryLight,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          InkWell(
            onTap: value > minValue ? () => onChanged(value - 1) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.remove,
                size: 16,
                color: value > minValue ? iconColor : AppColors.textHint,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ),
          // Increment button
          InkWell(
            onTap: value < maxValue ? () => onChanged(value + 1) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.add,
                size: 16,
                color: value < maxValue ? iconColor : AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
