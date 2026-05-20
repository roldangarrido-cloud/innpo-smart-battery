import '../data/mock_remote_diagnostics_repository.dart';
import '../data/remote_telemetry_mapper.dart';
import '../domain/remote_diagnostics_config.dart';
import 'remote_consent_service.dart';
import 'remote_diagnostic_service.dart';
import 'remote_session_timer.dart';

class MockRemoteDiagnosticService extends RemoteDiagnosticService {
  MockRemoteDiagnosticService({
    RemoteDiagnosticsConfig config = RemoteDiagnosticsConfig.mock,
    RemoteTelemetryMapper telemetryMapper = const RemoteTelemetryMapper(),
    RemoteConsentService consentService = const RemoteConsentService(),
    RemoteSessionTimer? sessionTimer,
  }) : super(
          repository: MockRemoteDiagnosticsRepository(),
          config: config,
          telemetryMapper: telemetryMapper,
          consentService: consentService,
          sessionTimer: sessionTimer,
        );
}
