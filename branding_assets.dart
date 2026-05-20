import 'package:flutter/material.dart';

class InnpoBrandingAssets {
  const InnpoBrandingAssets._();

  static const logo = 'assets/images/innpo_logo.png';
}

class InnpoLogo extends StatelessWidget {
  const InnpoLogo({
    this.size = 42,
    double? height,
    this.mode = InnpoLogoMode.light,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.centerLeft,
    this.safetyPadding = const EdgeInsets.all(4),
    super.key,
  }) : height = height ?? size;

  final double size;
  final double height;
  final InnpoLogoMode mode;
  final BoxFit fit;
  final Alignment alignment;
  final EdgeInsetsGeometry safetyPadding;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      InnpoBrandingAssets.logo,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      color: mode == InnpoLogoMode.monochromeLight ? Colors.white : null,
    );
    final logo = mode == InnpoLogoMode.dark
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: image,
          )
        : image;
    return Semantics(
      label: 'INNPO',
      image: true,
      child: Padding(
        padding: safetyPadding,
        child: logo,
      ),
    );
  }
}

enum InnpoLogoMode {
  light,
  dark,
  monochromeLight,
}
