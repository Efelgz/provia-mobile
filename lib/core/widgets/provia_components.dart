import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/app_theme.dart';

/// PROVIA ortak arayüz parçaları (Kişi 1 + Kişi 2).
/// İlke: kart çorbası yok. Listeler tek bir kenarlıklı yüzeyde, 1px
/// ayraçlarla; renk yalnızca durum ve veri için.

// ---------------------------------------------------------------------------
// Yerleşim
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

/// Sayfa gövdesi: içerik en fazla [maxWidth] genişlikte ortalanır,
/// kaydırma çubuğu ekranın kenarında kalır.
class ProviaPageView extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;

  const ProviaPageView({
    super.key,
    required this.children,
    this.maxWidth = 1040,
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
            wide ? 24 : 16,
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
                _SlackIntrinsicHeight(child: children[i]),
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
            _SlackIntrinsicHeight(
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
// Yüzeyler
// ---------------------------------------------------------------------------

/// 1px kenarlıklı, 8px köşeli temel yüzey. [onTap] verilirse hover'da
/// kenarlık bir ton açılır (parlama yok).
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
    final borderColor = widget.highlight || (_hovered && widget.onTap != null)
        ? ProviaTheme.borderStrong
        : ProviaTheme.borderDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 150),
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

/// Tek kenarlıklı panel: isteğe bağlı başlık satırı + 1px ayraçlı satırlar.
/// Liste öğelerini ayrı kartlara bölmek yerine bunu kullan.
class ProviaPanel extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final bool dividers;

  const ProviaPanel({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.dividers = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ProviaTheme.surfaceDark,
        borderRadius: BorderRadius.circular(ProviaTheme.radius),
        border: Border.all(color: ProviaTheme.borderDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: ProviaTheme.textSubtle,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
            const Divider(),
          ],
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0 && dividers) const Divider(),
            children[i],
          ],
        ],
      ),
    );
  }
}

class MetricItem {
  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final Color? valueColor;

  const MetricItem({
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.valueColor,
  });
}

/// Tek kenarlıklı metrik şeridi: genişte 4 sütun, dar ekranda 2x2;
/// sütunlar 1px ayraçla bölünür.
class MetricStrip extends StatelessWidget {
  final List<MetricItem> items;

  const MetricStrip({super.key, required this.items});

  Widget _cell(MetricItem item) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ProviaTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (item.icon != null)
              Icon(item.icon, size: 14, color: ProviaTheme.textSubtle),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ProviaTheme.mono(
            size: 22,
            weight: FontWeight.w600,
            color: item.valueColor ?? ProviaTheme.textPrimary,
          ),
        ),
        if (item.caption != null) ...[
          const SizedBox(height: 2),
          Text(
            item.caption!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ProviaTheme.textSubtle, fontSize: 11),
          ),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ProviaTheme.surfaceDark,
        borderRadius: BorderRadius.circular(ProviaTheme.radius),
        border: Border.all(color: ProviaTheme.borderDark),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 600 ? items.length : 2;
          final rows = <Widget>[];
          for (var start = 0; start < items.length; start += columns) {
            if (rows.isNotEmpty) rows.add(const Divider());
            rows.add(
              _SlackIntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var c = 0; c < columns; c++) ...[
                      if (c > 0) const VerticalDivider(width: 1),
                      Expanded(
                        child: start + c < items.length
                            ? _cell(items[start + c])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          return Column(children: rows);
        },
      ),
    );
  }
}

/// Nötr ikon kutusu (dekoratif; renk yalnızca gerekirse).
class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBox({
    super.key,
    required this.icon,
    this.color = ProviaTheme.textMuted,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ProviaTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
        border: Border.all(color: ProviaTheme.borderDark),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

// ---------------------------------------------------------------------------
// Etiketler ve metin
// ---------------------------------------------------------------------------

/// Küçük durum etiketi. Az kullan: çoğu meta bilgi düz metin olmalı.
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
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
                      fontWeight: FontWeight.w500,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sade teknoloji etiketi (monospace, dolgusuz).
class TechChip extends StatelessWidget {
  final String label;

  const TechChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
        border: Border.all(color: ProviaTheme.borderDark),
      ),
      child: Text(
        label,
        style: ProviaTheme.mono(size: 11, color: ProviaTheme.textMuted),
      ),
    );
  }
}

/// "a · b · c" biçiminde sade meta satırı.
String metaLine(Iterable<String> parts) =>
    parts.where((p) => p.trim().isNotEmpty).join('  ·  ');

/// Durum noktası (ör. Kanban sütun başlıkları).
class StatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const StatusDot(this.color, {super.key, this.size = 7});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatarlar (nötr)
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

class ProviaAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? borderColor;

  const ProviaAvatar({
    super.key,
    required this.name,
    this.size = 28,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ProviaTheme.surfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? ProviaTheme.borderStrong,
          width: borderColor != null ? 2 : 1,
        ),
      ),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: ProviaTheme.textMuted,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
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
    this.size = 24,
    this.max = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visible = names.take(max).toList();
    final extra = names.length - visible.length;
    final step = size * 0.7;
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
// Başlıklar, ilerleme, sekmeler
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
              Text(title, style: ProviaTheme.heading(size: 14)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: ProviaTheme.textSubtle,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
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
    this.height = 4,
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

/// Kompakt segment kontrol (ör. Giriş Yap / Kayıt Ol, Aylık / Yıllık).
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
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () => onChanged(s.value),
          child: Container(
            constraints: BoxConstraints(
              minHeight: minTapHeight(context, 28, 38),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
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
                      fontWeight: FontWeight.w500,
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
                      color: ProviaTheme.textSubtle,
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
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: ProviaTheme.surfaceDark,
        borderRadius: BorderRadius.circular(ProviaTheme.radius),
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

/// Metin + alt çizgi sekmeleri (filtreler, Kanban sekmeleri).
class UnderlineTabs<T> extends StatelessWidget {
  final List<ProviaSegment<T>> tabs;
  final T value;
  final ValueChanged<T> onChanged;

  const UnderlineTabs({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ProviaTheme.borderDark)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in tabs)
              InkWell(
                onTap: () => onChanged(t.value),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: minTapHeight(context, 38, 44),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: t.value == value
                            ? ProviaTheme.textPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: t.value == value
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: t.value == value
                              ? ProviaTheme.textPrimary
                              : ProviaTheme.textSubtle,
                        ),
                      ),
                      if (t.count != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${t.count}',
                          style: ProviaTheme.mono(
                            size: 11,
                            color: ProviaTheme.textSubtle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Seçilebilir filtre hapı (eski ekran uyumluluğu için).
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
      color: selected ? ProviaTheme.surfaceElevated : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
        side: BorderSide(
          color: selected ? ProviaTheme.borderStrong : ProviaTheme.borderDark,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: minTapHeight(context, 32, 44)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
            height: 36,
            child: Row(
              children: [
                Expanded(
                  child: Text(o.$2, style: const TextStyle(fontSize: 13)),
                ),
                if (o.$1 == value)
                  const Icon(Icons.check, size: 15, color: ProviaTheme.primary),
              ],
            ),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ProviaTheme.surfaceDark,
          borderRadius: BorderRadius.circular(ProviaTheme.radiusSmall),
          border: Border.all(
            color: active ? ProviaTheme.borderStrong : ProviaTheme.borderDark,
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
                      style: const TextStyle(color: ProviaTheme.textSubtle),
                    ),
                    TextSpan(
                      text: current,
                      style: const TextStyle(
                        color: ProviaTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more,
              size: 16,
              color: ProviaTheme.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Geri alınabilir aksiyon butonu (davet / başvuru)
// ---------------------------------------------------------------------------

/// Üç durumlu buton:
/// 1) [label] (ör. "Davet Et") → dokununca [onActivate]
/// 2) [activeLabel] ✓ (ör. "Davet gönderildi") → tekrar dokununca [onUndo]
/// 3) kısa süre [undoneLabel] (ör. "Davet iptal edildi"), sonra 1'e döner.
class ToggleActionButton extends StatefulWidget {
  final bool active;
  final String label;
  final String activeLabel;
  final String undoneLabel;
  final VoidCallback onActivate;
  final VoidCallback onUndo;
  final bool primary;
  final IconData? icon;

  const ToggleActionButton({
    super.key,
    required this.active,
    required this.label,
    required this.activeLabel,
    required this.undoneLabel,
    required this.onActivate,
    required this.onUndo,
    this.primary = false,
    this.icon,
  });

  @override
  State<ToggleActionButton> createState() => _ToggleActionButtonState();
}

class _ToggleActionButtonState extends State<ToggleActionButton> {
  static const _flashDuration = Duration(milliseconds: 1600);

  Timer? _timer;
  bool _showUndone = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _undo() {
    widget.onUndo();
    _timer?.cancel();
    setState(() => _showUndone = true);
    _timer = Timer(_flashDuration, () {
      if (mounted) setState(() => _showUndone = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showUndone && !widget.active) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.close, size: 13),
        label: Text(widget.undoneLabel),
      );
    }
    if (widget.active) {
      return Tooltip(
        message: 'Geri almak için tıkla',
        child: OutlinedButton.icon(
          onPressed: _undo,
          style: OutlinedButton.styleFrom(
            foregroundColor: ProviaTheme.accent,
            side: BorderSide(color: ProviaTheme.accent.withValues(alpha: 0.4)),
          ),
          icon: const Icon(Icons.check, size: 14),
          label: Text(widget.activeLabel),
        ),
      );
    }
    final icon = widget.icon;
    if (widget.primary) {
      return icon == null
          ? ElevatedButton(
              onPressed: widget.onActivate,
              child: Text(widget.label),
            )
          : ElevatedButton.icon(
              onPressed: widget.onActivate,
              icon: Icon(icon, size: 13),
              label: Text(widget.label),
            );
    }
    return icon == null
        ? OutlinedButton(
            onPressed: widget.onActivate,
            child: Text(widget.label),
          )
        : OutlinedButton.icon(
            onPressed: widget.onActivate,
            icon: Icon(icon, size: 13),
            label: Text(widget.label),
          );
  }
}

// ---------------------------------------------------------------------------
// Eşit yükseklik (güvenlik paylı)
// ---------------------------------------------------------------------------

/// IntrinsicHeight gibi çalışır ama ölçülen yüksekliğe küçük bir pay ekler.
/// Debug modunda font yüklenirken metin ölçümü birkaç piksel düşük
/// kalabiliyor; bu pay "BOTTOM OVERFLOWED BY 3 PIXELS" hatasını önler.
class _SlackIntrinsicHeight extends SingleChildRenderObjectWidget {
  static const double slack = 4;

  const _SlackIntrinsicHeight({required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSlackIntrinsicHeight(slack);
}

class _RenderSlackIntrinsicHeight extends RenderProxyBox {
  _RenderSlackIntrinsicHeight(this._slack);

  final double _slack;

  double _height(double width) =>
      (child?.getMaxIntrinsicHeight(width) ?? 0) + _slack;

  @override
  double computeMinIntrinsicHeight(double width) => _height(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _height(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    final height = constraints.constrainHeight(_height(constraints.maxWidth));
    return child.getDryLayout(constraints.tighten(height: height));
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final height = constraints.constrainHeight(_height(constraints.maxWidth));
    child.layout(constraints.tighten(height: height), parentUsesSize: true);
    size = constraints.constrain(child.size);
  }
}
