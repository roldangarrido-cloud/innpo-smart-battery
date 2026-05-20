import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'branding.dart';
import 'localization/l10n.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class InnpoApp extends StatelessWidget {
  const InnpoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: InnpoBranding.appName,
      debugShowCheckedModeBanner: false,
      theme: InnpoTheme.light(),
      darkTheme: InnpoTheme.dark(),
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
    );
  }
}
