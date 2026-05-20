import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/branding_assets.dart';
import '../../../app/localization/l10n.dart';
import '../../../app/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      _OnboardingPageData(
        title: l10n.appName,
        claim: l10n.appClaim,
        text: l10n.onboardingDescription,
        icon: const _LogoBatteryBluetoothIcon(),
        primaryButtonLabel: 'Comenzar',
      ),
      const _OnboardingPageData(
        title: 'Monitorización en tiempo real',
        text:
            'Consulta carga, voltaje, corriente, temperatura, ciclos y estado de las celdas desde tu móvil.',
        icon: Icon(Icons.monitor_heart_outlined, size: 80),
      ),
      const _OnboardingPageData(
        title: 'Diagnóstico y soporte',
        text:
            'Detecta avisos, genera informes técnicos y comparte el estado de tu batería con soporte INNPO.',
        icon: Icon(Icons.assignment_turned_in_outlined, size: 80),
      ),
    ];
    final isLastPage = _page == pages.length - 1;
    final currentPage = pages[_page];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: pages[index]);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: i == _page ? 22 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == _page
                            ? AppColors.primaryBlue
                            : AppColors.separator,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_page == 0 || isLastPage) {
                      context.go('/scan');
                      return;
                    }
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Text(
                    currentPage.primaryButtonLabel ??
                        (isLastPage ? 'Comenzar' : 'Siguiente'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.primary),
          child: data.icon,
        ),
        const SizedBox(height: 32),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        if (data.claim != null) ...[
          const SizedBox(height: 8),
          Text(
            data.claim!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          data.text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
        ),
      ],
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.text,
    required this.icon,
    this.claim,
    this.primaryButtonLabel,
  });

  final String title;
  final String text;
  final Widget icon;
  final String? claim;
  final String? primaryButtonLabel;
}

class _LogoBatteryBluetoothIcon extends StatelessWidget {
  const _LogoBatteryBluetoothIcon();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.subtleShadow,
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const InnpoLogo(height: 50),
        ),
        const SizedBox(height: 30),
        const _BatteryBluetoothIcon(),
      ],
    );
  }
}

class _BatteryBluetoothIcon extends StatelessWidget {
  const _BatteryBluetoothIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.battery_charging_full, size: 96),
        Positioned(
          right: 0,
          bottom: 4,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bluetooth,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
