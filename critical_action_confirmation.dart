import 'package:flutter/material.dart';

class CriticalActionConfirmation {
  const CriticalActionConfirmation._();

  static Future<bool> request(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

