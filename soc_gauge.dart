import 'package:flutter/material.dart';

class SocGauge extends StatelessWidget {
  const SocGauge({
    required this.socPercent,
    required this.statusText,
    required this.color,
    this.size = 164,
    super.key,
  });

  final double socPercent;
  final String statusText;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final progress = (socPercent / 100).clamp(0.0, 1.0).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: size - 10,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${socPercent.round()}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    'Carga',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          statusText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

