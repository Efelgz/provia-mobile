import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// PROVIA marka işareti (P + turuncu nokta).
class ProviaLogoMark extends StatelessWidget {
  final double size;

  const ProviaLogoMark({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/provia_mark.png',
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'PROVIA logosu',
    );
  }
}

/// "PROVIA" yazı logosu (turuncu A ile).
class ProviaWordmark extends StatelessWidget {
  final double height;

  const ProviaWordmark({super.key, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/provia_wordmark.png',
      height: height,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
  }
}

/// İşaret + yazı logosu; isteğe bağlı Türkçe alt slogan.
class ProviaLogo extends StatelessWidget {
  final double height;
  final bool showTagline;

  const ProviaLogo({super.key, this.height = 28, this.showTagline = false});

  @override
  Widget build(BuildContext context) {
    final wordHeight = height * (showTagline ? 0.5 : 0.56);
    return Semantics(
      label: 'PROVIA',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProviaLogoMark(size: height),
          SizedBox(width: height * 0.32),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProviaWordmark(height: wordHeight),
                if (showTagline) ...[
                  SizedBox(height: height * 0.1),
                  // Dar ekranda slogan taşmak yerine küçülür.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ÖĞRENCİ TAKIM ÇALIŞMASI & STAJ',
                      style: TextStyle(
                        color: ProviaTheme.textSubtle,
                        fontSize: (height * 0.17).clamp(9.0, 14.0),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
