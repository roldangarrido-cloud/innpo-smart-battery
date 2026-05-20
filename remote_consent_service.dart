import '../domain/remote_support_consent.dart';

class RemoteConsentService {
  const RemoteConsentService();

  RemoteSupportConsent acceptConsent({
    String consentTextVersion = 'remote-support-consent-v1',
  }) {
    return RemoteSupportConsent.acceptedNow(
      consentTextVersion: consentTextVersion,
    );
  }

  void validate(RemoteSupportConsent consent) {
    if (!consent.accepted) {
      throw StateError(
        'El diagnostico remoto requiere consentimiento explicito del cliente.',
      );
    }
    if (consent.sharedDataCategories.isEmpty) {
      throw StateError(
        'El consentimiento debe indicar las categorias de datos compartidos.',
      );
    }
  }
}
