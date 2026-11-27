import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// PROVIA ortak arayüz parçaları. Tüm ekranlar aynı görünsün diye
/// buradan kullanılır (Kişi 1 + Kişi 2).

// ---------------------------------------------------------------------------
// Yerleşim yardımcıları
// ---------------------------------------------------------------------------

class ProviaBreakpoints {
  /// Bu genişlik ve üstünde masaüstü yerleşimi (sol menü) kullanılır.
  static const double desktop = 900;

  /// İçerik alanı bu genişliğin üstündeyse çok sütunlu yerleşim kullanılır.
  static const double twoColumn = 720;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}

/// Masaüstünde kompakt, mobilde parmakla rahat dokunulacak minimum yükseklik.
double minTapHeight(BuildContext context, double desktop, double mobile) =>
    ProviaBreakpoints.isDesktop(context) ? desktop : mobile;

/// Sayfa gövdesi: içeriği en fazla [maxWidth] genişlikte ortalar,
/// kaydırma çubuğu ise ekranın kenarında kalır.
class ProviaPageView extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;

  const ProviaPageView({
    super.key,
    required this.children,
    this.maxWidth = 1160,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= ProviaBreakpoints.twoColumn;
        final minPadding = wide ? 32.0 : 16.0;
        final horizontal = math.max(
          minPadding,
          (constraints.maxWidth - maxWidth) / 2,
        );
        return ListView(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            wide ? 28 : 16,
            horizontal,
            32,
          ),
          children: children,
        );
      },
    );
  }
}

/// Eşit yükseklikli satırlardan oluşan duyarlı ızgara.
/// Not: Çocuklar LayoutBuilder içermemeli (IntrinsicHeight kullanılır).
class ProviaGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;

  const ProviaGrid({
    super.key,
    required this.children,
    this.minItemWidth = 300,
    this.maxColumns = 2,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit =
            ((constraints.maxWidth + spacing) / (minItemWidth + spacing))
                .floor();
        final columns = fit.clamp(1, maxColumns);
        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                // Kart içinde Spacer kullanılabilsin diye yükseklik sınırlanır.
                IntrinsicHeight(child: children[i]),
              ],
            ],
          );
        }
        final rows = <Widget>[];
        for (var start = 0; start < children.length; start += columns) {
          final rowItems = <Widget>[];
          for (var c = 0; c < columns; c++) {
            final index = start + c;
            if (c > 0) rowItems.add(SizedBox(width: spacing));
            rowItems.add(
              Expanded(
                child: index < children.length
                    ? children[index]
                    : const SizedBox.shrink(),
              ),
            );
          }
          if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rowItems,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Kartlar
// ---------------------------------------------------------------------------

/// İnce kenarlıklı, 12px köşeli temel kart. [onTap] verilirse fareyle
/// üzerine gelince kenarlık vurgulanır.
class ProviaCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlight;
  final VoidCallback? onTap;
  final Color? color;

  const ProviaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.highlight = false,
    this.onTap,
    this.color,
  });

  @override
  State<ProviaCard> createState() => _ProviaCardState();
}

class _ProviaCardState extends State<ProviaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.highlight
        ? ProviaTheme.borderHighlight
        : (_hovered && widget.onTap != null
              ? ProviaTheme.borderStrong
              : ProviaTheme.borderDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: widget.color ?? ProviaTheme.surfaceDark,
          borderRadius: BorderRadius.circular(ProviaTheme.radius),
          border: Border.all(color: borderColor),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(ProviaTheme.radius),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// İkon (yumuşak renkli kare içinde) + monospace büyük değer + soluk etiket.
class MetricStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? caption;

  const MetricStatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return ProviaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBox(icon: icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ProviaTheme.mono(size: 22, weight: FontWeight.w700),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ProviaTheme.textSubtle,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Yumuşak renkli yuvarlatılmış kare içinde ikon.
class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

// ---------------------------------------------------------------------------
// Etiketler
// ---------------------------------------------------------------------------

/// Renkli, kompakt durum etiketi (ör. "Şirket Destekli", "Orta", "Doğrulandı").
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool mono;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mono
                  ? ProviaTheme.mono(size: 11, color: color)
                  : TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nötr teknoloji etiketi (ör. "Flutter", "PostgreSQL").
class TechChip extends StatelessWidget {
  final String label;

  const TechChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ProviaTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ProviaTheme.borderDark),
      ),
      child: Text(
        label,
        style: ProviaTheme.mono(
          size: 11,
          weight: FontWeight.w500,
          color: ProviaTheme.textMuted,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatarlar
// ---------------------------------------------------------------------------

/// "Selin Demir" -> "SD". "(Sen)" eki yok sayılır.
String initialsOf(String name) {
  final parts = name
      .replaceAll('(Sen)', '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((p) => p.characters.first).join().toUpperCase();
}

const _avatarColors = [
  Color(0xFFF97316),
  Color(0xFF38BDF8),
  Color(0xFF10B981),
  Color(0xFFFBBF24),
  Color(0xFFF472B6),
  Color(0xFFA78BFA),
];

/// İsimden sabit bir avatar rengi üretir.
Color avatarColorFor(String name) =>
    _avatarColors[name.codeUnits.fold(0, (a, b) => a + b) %
        _avatarColors.length];

class ProviaAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? borderColor;

  const ProviaAvatar({
    super.key,
    required this.name,
    this.size = 32,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = avatarColorFor(name);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: 0.22),
          ProviaTheme.surfaceDark,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? color.withValues(alpha: 0.45),
          width: borderColor != null ? 2 : 1,
        ),
      ),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: Color.lerp(color, Colors.white, 0.35),
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Üst üste binen takım üyesi avatarları.
class AvatarStack extends StatelessWidget {
  final List<String> names;
  final double size;
  final int max;

  const AvatarStack({
    super.key,
    required this.names,
    this.size = 28,
    this.max = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visible = names.take(max).toList();
    final extra = names.length - visible.length;
    final step = size * 0.68;
    final count = visible.length + (extra > 0 ? 1 : 0);

    return Tooltip(
      message: names.map((n) => n.replaceAll('(Sen)', '').trim()).join(', '),
      child: SizedBox(
        width: count == 0 ? 0 : step * (count - 1) + size,
        height: size,
        child: Stack(
          children: [
            for (var i = 0; i < visible.length; i++)
              Positioned(
                left: step * i,
                child: ProviaAvatar(
                  name: visible[i],
                  size: size,
                  borderColor: ProviaTheme.surfaceDark,
                ),
              ),
            if (extra > 0)
              Positioned(
                left: step * visible.length,
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ProviaTheme.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ProviaTheme.surfaceDark,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '+$extra',
                    style: ProviaTheme.mono(
                      size: size * 0.34,
                      color: ProviaTheme.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Başlıklar, ilerleme, segment kontrol
// ---------------------------------------------------------------------------

/// Bölüm başlığı + isteğe bağlı alt başlık + sağda bağlantı.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ProviaTheme.heading(size: 15)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: ProviaTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// İnce, gradyansız ilerleme çubuğu.
class ProviaProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const ProviaProgressBar({
    super.key,
    required this.value,
    this.color = ProviaTheme.primary,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: ProviaTheme.borderDark,
        color: color,
      ),
    );
  }
}

class ProviaSegment<T> {
  final T value;
  final String label;
  final int? count;

  const ProviaSegment(this.value, this.label, {this.count});
}

/// Keskin, kompakt segment kontrol (ör. Giriş Yap / Kayıt Ol, Aylık / Yıllık).
class ProviaSegmented<T> extends StatelessWidget {
  final List<ProviaSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;
  final bool expand;

  const ProviaSegmented({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget item(ProviaSegment<T> s) {
      final selected = s.value == value;
      final child = Material(
        color: selected ? ProviaTheme.surfaceElevated : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onChanged(s.value),
          child: Container(
            // Mobilde dokunma hedefi >= 44px (dış dolgu + kenarlık dahil).
            constraints: BoxConstraints(
              minHeight: minTapHeight(context, 30, 38),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ProviaTheme.borderStrong),
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? ProviaTheme.textPrimary
                          : ProviaTheme.textMuted,
                    ),
                  ),
                ),
                if (s.count != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '${s.count}',
                    style: ProviaTheme.mono(
                      size: 11,
                      color: selected
                          ? ProviaTheme.primary
                          : ProviaTheme.textSubtle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      return expand ? Expanded(child: child) : child;
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ProviaTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ProviaTheme.borderDark),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            item(segments[i]),
          ],
        ],
      ),
    );
  }
}

/// Seçilebilir filtre hapı (Keşfet filtreleri vb.).
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? ProviaTheme.primary.withValues(alpha: 0.16)
          : ProviaTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected
              ? ProviaTheme.borderHighlight
              : ProviaTheme.borderDark,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: minTapHeight(context, 34, 44)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? ProviaTheme.textPrimary : ProviaTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metin yardımcıları
// ---------------------------------------------------------------------------

/// Aramada Türkçe karakter farkını yok sayar: "KOBİ" ~ "kobi", "Şirket" ~ "sirket".
String foldForSearch(String input) {
  const map = {
    'ç': 'c',
    'ğ': 'g',
    'ı': 'i',
    'ö': 'o',
    'ş': 's',
    'ü': 'u',
    'Ç': 'c',
    'Ğ': 'g',
    'I': 'i',
    'İ': 'i',
    'Ö': 'o',
    'Ş': 's',
    'Ü': 'u',
  };
  final buffer = StringBuffer();
  for (final ch in input.characters) {
    buffer.write(map[ch] ?? ch.toLowerCase());
  }
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Filtre seçici ("Teknoloji: Tümü ▾")
// ---------------------------------------------------------------------------

class ProviaSelect<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  const ProviaSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final current = options
        .firstWhere((o) => o.$1 == value, orElse: () => options.first)
        .$2;
    final active = value != options.first.$1;

    return PopupMenuButton<T>(
      tooltip: '$label seç',
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        for (final o in options)
          PopupMenuItem<T>(
            value: o.$1,
            child: Row(
              children: [
                Expanded(
                  child: Text(o.$2, style: const TextStyle(fontSize: 13)),
                ),
                if (o.$1 == value)
                  const Icon(Icons.check, size: 16, color: ProviaTheme.primary),
              ],
            ),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: ProviaTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? ProviaTheme.borderHighlight
                : ProviaTheme.borderDark,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: const TextStyle(color: ProviaTheme.textMuted),
                    ),
                    TextSpan(
                      text: current,
                      style: TextStyle(
                        color: active
                            ? ProviaTheme.primary
                            : ProviaTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.expand_more,
              size: 18,
              color: ProviaTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
