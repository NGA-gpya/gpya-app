import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/src/features/tools/diagnostic_models.dart';
import 'package:myapp/src/features/dashboard/document_model.dart';
import 'package:myapp/src/features/tools/widgets/risk_gauge.dart';
import 'package:myapp/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DiagnosticResultScreen extends StatelessWidget {
  final DiagnosticResult result;

  const DiagnosticResultScreen({super.key, required this.result});

  Future<void> _launchWhatsApp() async {
    const phoneNumber = "525583252920";
    final message =
        "Hola, realicé el diagnóstico de ${result.category.displayName} y obtuve un nivel de riesgo ${result.riskLevel}. Me gustaría asesoría profesional.";
    final whatsappUrl =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
    final Uri uri = Uri.parse(whatsappUrl);
    if (!await launchUrl(uri)) {
      throw Exception('No se pudo lanzar WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color riskColor;
    String riskTitle;
    String message;

    switch (result.riskLevel) {
      case 'Bajo':
        riskColor = Colors.green;
        riskTitle = 'CUMPLIMIENTO ALTO';
        message =
            '¡Excelente! Su centro de trabajo cumple con la mayoría de los puntos evaluados. Mantenga la mejora continua.';
      case 'Medio':
        riskColor = Colors.orange;
        riskTitle = 'RIESGO MODERADO';
        message =
            'Existen áreas de oportunidad críticas. Se recomienda revisar los puntos detectados para evitar sanciones legales.';
      default:
        riskColor = Colors.red;
        riskTitle = 'ALTO RIESGO';
        message =
            '¡Atención! Riesgo Crítico detectado. Es urgente implementar medidas correctivas para cumplir con la normativa oficial.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de Cumplimiento'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  opacity: 0.05,
                  blur: 15,
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      RiskGauge(
                        percentage: result.percentage / 100,
                        size: 240,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        riskTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ).animate().fade(delay: 500.ms).scale(),
                      const SizedBox(height: 32),
                      _StatRow(result: result),
                    ],
                  ).animate().fade().slideY(begin: 0.1),
                ),

                const SizedBox(height: 24),

                // Resumen Mensaje (Usando la variable 'message' que estaba sin uso)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: riskColor.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ).animate().fade(delay: 800.ms),

                const SizedBox(height: 48),

                // NEW: Norm Compliance Dashboard
                Text(
                  'DASHBOARD DE CUMPLIMIENTO (NOM)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                _NormDashboard(normCompliance: result.normCompliance),

                const SizedBox(height: 48),

                // Recomendaciones
                if (result.recommendations.isNotEmpty) ...[
                  Text(
                    'PUNTOS DE MEJORA PRIORITARIOS',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...result.recommendations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final rec = entry.value;
                    return _RecommendationItem(
                      index: index,
                      text: rec,
                    );
                  }),
                ],

                const SizedBox(height: 48),

                // WhatsApp Action Section
                GlassCard(
                  padding: const EdgeInsets.all(28),
                  opacity: 0.8,
                  color: const Color(0xFF25D366).withValues(alpha: 0.1),
                  child: Column(
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          color: Color(0xFF25D366), size: 40),
                      const SizedBox(height: 16),
                      Text(
                        'Asesoría Profesional GPYA',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Podemos ayudarte a solventar los puntos críticos y preparar a tu empresa para auditorías de la STPS.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _launchWhatsApp,
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('CONSULTAR POR WHATSAPP'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 1500.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/'),
                    child: Text(
                      'SALIR DE LA EVALUACIÓN',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final DiagnosticResult result;

  const _StatRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          label: 'CUMPLIDOS',
          value: '${result.score}',
          color: Colors.green,
        ),
        const SizedBox(
          height: 40,
          child: VerticalDivider(width: 1),
        ),
        _StatItem(
          label: 'POR EVALUAR',
          value: '${result.totalQuestions - result.score}',
          color: Colors.redAccent,
        ),
      ],
    );
  }
}

class _NormDashboard extends StatelessWidget {
  final Map<String, double> normCompliance;

  const _NormDashboard({required this.normCompliance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: normCompliance.entries.map((entry) {
        final norm = entry.key;
        final percent = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    norm,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _getColor(percent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 10,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(_getColor(percent)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColor(double p) {
    if (p >= 0.8) return Colors.green;
    if (p >= 0.5) return Colors.orange;
    return Colors.redAccent;
  }
}

class _RecommendationItem extends StatelessWidget {
  final int index;
  final String text;

  const _RecommendationItem({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline, size: 16, color: Colors.amber),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ).animate().fade(delay: Duration(milliseconds: 1000 + (index * 100))).slideX(begin: 0.05),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
