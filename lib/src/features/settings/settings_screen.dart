import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:myapp/src/features/settings/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('No se pudo lanzar $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: <Widget>[
          // Sección de Apariencia
          _buildSectionCard(
            theme,
            title: 'Apariencia',
            children: [_buildThemeSwitch(ref)],
          ),
          const SizedBox(height: 20),

          // Sección de Ayuda
          _buildSectionCard(
            theme,
            title: 'Ayuda y Soporte',
            children: [
              ListTile(
                leading: Icon(
                  Icons.support_agent_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Contactar Soporte Técnico'),
                subtitle: const Text(
                  'area.tecnica@grupopadillayaguilar.com.mx',
                ),
                onTap: () => _launchUrl(
                  'mailto:area.tecnica@grupopadillayaguilar.com.mx',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sección Legal
          _buildSectionCard(
            theme,
            title: 'Información Legal',
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Términos y Condiciones'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLegalNotice(
                  context,
                  'Términos y Condiciones',
                  _termsAndConditionsText,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Política de Privacidad'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLegalNotice(
                  context,
                  'Política de Privacidad',
                  _privacyPolicyText,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: const Text('Licencias de Código Abierto'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'GPYA',
                  applicationLegalese: '© 2026 Grupo Padilla y Aguilar',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLegalNotice(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.8),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ENTENDIDO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const String _privacyPolicyText = '''
POLÍTICA DE PRIVACIDAD GPYA

GPYA se compromete a proteger la privacidad de sus usuarios. Esta Política de Privacidad describe cómo tratamos la información en nuestra aplicación.

1. Recopilación de Información:
Nuestra aplicación es de carácter informativo y preventivo. No recopilamos datos personales identificables, nombres, direcciones de correo electrónico o números de teléfono a menos que usted decida contactarnos directamente para una asesoría.

2. Uso de la Información:
La información proporcionada en los autodiagnósticos es local y se utiliza únicamente para generar el reporte de cumplimiento en su pantalla. Esta información no se almacena en servidores externos ni se comparte con terceros sin su consentimiento expreso.

3. Seguridad:
Implementamos medidas de seguridad para proteger la integridad de la aplicación y la información que usted visualiza.

4. Contacto:
Para cualquier duda sobre su privacidad, puede contactarnos en: area.tecnica@grupopadillayaguilar.com.mx
''';

  static const String _termsAndConditionsText = '''
TÉRMINOS Y CONDICIONES GPYA

Al utilizar la aplicación GPYA, usted acepta los siguientes términos:

1. Uso del Contenido:
El contenido proporcionado en esta aplicación, incluyendo los autodiagnósticos y las recomendaciones normativas, es de carácter informativo y preventivo. No sustituye una auditoría formal o asesoría legal presencial.

2. Limitación de Responsabilidad:
GPYA no se hace responsable por el uso indebido de la información proporcionada o por interpretaciones erróneas de los resultados del autodiagnóstico. Los resultados son una guía preliminar basada en las respuestas proporcionadas por el usuario.

3. Propiedad Intelectual:
Todos los logotipos, textos y diseños de esta aplicación son propiedad de Grupo Padilla y Aguilar.

4. Modificaciones:
Nos reservamos el derecho de actualizar estos términos en cualquier momento. El uso continuado de la aplicación implica la aceptación de los nuevos términos.
''';

  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSwitch(WidgetRef ref) {
    final currentMode = ref.watch(themeProvider);

    final options = {
      'Modo Claro': ThemeMode.light,
      'Modo Oscuro': ThemeMode.dark,
      'Automático (Sistema)': ThemeMode.system,
    };

    final icons = {
      ThemeMode.light: Icons.wb_sunny_outlined,
      ThemeMode.dark: Icons.nightlight_round_outlined,
      ThemeMode.system: Icons.brightness_auto_outlined,
    };

    return Column(
      children: options.entries.map((entry) {
        final title = entry.key;
        final value = entry.value;

        return ListTile(
          leading: Icon(icons[value]),
          title: Text(title),
          trailing: Radio<ThemeMode>(
            value: value,
            // ignore: deprecated_member_use
            groupValue: currentMode,
            // ignore: deprecated_member_use
            onChanged: (newValue) {
              if (newValue != null) {
                ref.read(themeProvider.notifier).setTheme(newValue);
              }
            },
          ),
          onTap: () {
            ref.read(themeProvider.notifier).setTheme(value);
          },
        );
      }).toList(),
    );
  }
}
