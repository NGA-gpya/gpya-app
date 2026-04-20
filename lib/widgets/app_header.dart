import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51), // Opacidad válida
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1), // Sombra
          ),
        ],
      ),
      child: SafeArea(
        bottom: false, // Sin padding inferior en SafeArea
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // USA EL ICONO CORRECTO DE LA APP
            Image.asset('assets/icon/icon-app.jpg', height: 40),
            const SizedBox(width: 12),
            // Nombre de la empresa flexible
            Expanded(
              child: Text(
                'Grupo Padilla y Aguilar',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
