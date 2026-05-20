import 'package:flutter/material.dart';

import '../../../../shared/widgets/innpo_primary_button.dart';

class DiagnosticSummaryCard extends StatelessWidget {
  const DiagnosticSummaryCard({
    required this.status,
    required this.summary,
    required this.color,
    required this.onCreateReport,
    super.key,
  });

  final String status;
  final String summary;
  final Color color;
  final VoidCallback onCreateReport;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fact_check_outlined, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(summary),
            const SizedBox(height: 14),
            InnpoPrimaryButton(
              onPressed: onCreateReport,
              icon: Icons.picture_as_pdf_outlined,
              label: 'Generar informe',
            ),
          ],
        ),
      ),
    );
  }
}
