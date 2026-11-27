import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../models/provia_models.dart';
import 'provia_components.dart';

/// Katılınan projeler arasında geçiş yapmak için yatay seçim çubuğu.
/// Panel ve Alanım ekranları ortak kullanır.
class ProjectSwitcher extends StatelessWidget {
  final List<ProviaProject> projects;
  final String activeProjectId;
  final ValueChanged<String> onSelect;

  const ProjectSwitcher({
    super.key,
    required this.projects,
    required this.activeProjectId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minTapHeight(context, 36, 44),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final project = projects[index];
          final selected = project.id == activeProjectId;
          return Material(
            color: selected
                ? ProviaTheme.primary.withValues(alpha: 0.2)
                : ProviaTheme.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: selected
                    ? ProviaTheme.primary.withValues(alpha: 0.6)
                    : ProviaTheme.borderDark,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onSelect(project.id),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      project.title,
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
