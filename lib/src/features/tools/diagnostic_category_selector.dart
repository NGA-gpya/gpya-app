import 'package:flutter/material.dart';
import 'package:myapp/src/features/dashboard/document_model.dart';
import 'package:myapp/src/features/tools/diagnostic_models.dart';
import 'package:go_router/go_router.dart';

class DiagnosticCategorySelector extends StatelessWidget {
  const DiagnosticCategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filtrar categorías que tienen preguntas
    final categories = DocumentCategory.values.where((cat) {
      return diagnosticQuestions.any((q) => q.category == cat);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autodiagnóstico NOM'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccione un área para evaluar',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Realice una breve evaluación para conocer su nivel de cumplimiento con las Normas Oficiales Mexicanas.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryCard(category: category);
              },
            ),
            const SizedBox(height: 40),
            _InfoCard(theme: theme),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final DocumentCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData icon;
    Color color;

    switch (category) {
      case DocumentCategory.seguridad:
        icon = Icons.shield_outlined;
        color = Colors.blue;
      case DocumentCategory.salud:
        icon = Icons.health_and_safety_outlined;
        color = Colors.green;
      case DocumentCategory.organizacion:
        icon = Icons.assignment_outlined;
        color = Colors.orange;
      case DocumentCategory.especificas:
        icon = Icons.construction_outlined;
        color = Colors.purple;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/diagnostic/${category.name}'),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Evaluar riesgos de ${category.shortName.toLowerCase()}.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ThemeData theme;
  const _InfoCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Los resultados son orientativos y no sustituyen una auditoría formal de la STPS.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
