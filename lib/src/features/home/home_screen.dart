import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myapp/widgets/app_header.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('No se pudo lanzar $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const phoneNumber = "525583252920";
    const message = "Hola quiero más información sobre...";
    final whatsappUrl =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light
          ? const Color(0xFFFAFAFA)
          : const Color(0xFF121212),
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Refined Header/Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 48, 28, 80),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                    theme.brightness == Brightness.light
                        ? const Color(0xFFFAFAFA)
                        : const Color(0xFF121212),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seguridad y\nCumplimiento',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1.5,
                    ),
                  ).animate().fade(duration: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  Text(
                    'Asesoría legal estratégica y\ngestión de riesgos para su empresa.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                ],
              ),
            ),

            // Overlapping Diagnostic Card
            Transform.translate(
              offset: const Offset(0, -40),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: _DiagnosticBanner(),
              ),
            ),

            // Features & Contact
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const _FeatureHighlight(),
                  const SizedBox(height: 56),
                  _ContactInfo(launchUrl: _launchUrl),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _launchUrl(whatsappUrl),
        backgroundColor: Colors.transparent,
        elevation: 8,
        tooltip: 'Contactar por WhatsApp',
        child: Image.asset('assets/icon/logo-wp.png')
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 2.seconds,
            ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final Future<void> Function(String) launchUrl;
  const _ContactInfo({required this.launchUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.contact_support_outlined,
                  color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'CONTACTO',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ContactCard(
          icon: Icons.location_on_outlined,
          title: 'Ubicación',
          subtitle: 'Tecamac, Estado de México',
          onTap: () => launchUrl(
              'https://www.google.com/maps/search/?api=1&query=Lomas+de+Tecamac+Estado+de+Mexico'),
        ),
        const SizedBox(height: 12),
        _ContactCard(
          icon: Icons.phone_outlined,
          title: 'Llámanos',
          subtitle: '55 8325 2920',
          onTap: () => launchUrl('tel:5583252920'),
        ),
        const SizedBox(height: 12),
        _ContactCard(
          icon: Icons.email_outlined,
          title: 'Correo',
          subtitle: 'proyectos@gpya.com.mx',
          onTap: () => launchUrl('mailto:proyectos@gpya.com.mx'),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? Colors.white
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5))),
                  Text(subtitle,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticBanner extends StatelessWidget {
  const _DiagnosticBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(28),
      opacity: theme.brightness == Brightness.light ? 0.8 : 0.05,
      blur: 20,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Herramientas de Control',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '¿Su empresa cumple con las Normas Oficiales?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Autodiagnóstico rápido basado en estándares de Seguridad y Salud.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/diagnostic'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Comenzar Evaluación',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureHighlight extends StatelessWidget {
  const _FeatureHighlight();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FeatureItem(
          icon: Icons.shield_outlined,
          title: 'Cumplimiento',
          description:
              'En un entorno que evoluciona rápidamente, la capacitación continua no solo es un aspecto deseable, sino una necesidad crítica.',
        ),
        const _FeatureItem(
          icon: Icons.gavel_rounded,
          title: 'Asesoría',
          description:
              'Planes de cumplimiento integral para tu empresa o institución.',
        ),
        const _FeatureItem(
          icon: Icons.health_and_safety_outlined,
          title: 'Consultoría',
          description:
              'Solución integral a las necesidades de tu empresa en materia de estudios de ambiente laboral y normas oficiales mexicanas.',
        ),
      ].animate(interval: 200.ms).fade().slideX(begin: 0.2),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
