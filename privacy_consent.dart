import 'package:flutter/material.dart';

class PrivacyConsent {
  const PrivacyConsent._();

  static Future<bool> requestDiagnosticShareConsent(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartir diagnóstico'),
        content: const Text(
          'INNPO Smart Battery no envía datos automáticamente. Se compartirá el diagnóstico solo si confirmas esta acción.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Compartir'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<bool> requestRemoteDiagnosticConsent(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Autorizar diagnóstico remoto'),
        content: const Text(
          'Vas a iniciar una sesión temporal para que soporte INNPO pueda visualizar datos de lectura de tu batería. No permite controlar tu móvil, no modifica el BMS y puedes detenerla en cualquier momento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Autorizar 15 min'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
