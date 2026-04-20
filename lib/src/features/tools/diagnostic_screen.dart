import 'package:flutter/material.dart';
import 'package:myapp/src/features/dashboard/document_model.dart';
import 'package:myapp/src/features/tools/diagnostic_models.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

class DiagnosticScreen extends StatefulWidget {
  final String categoryName;

  const DiagnosticScreen({super.key, required this.categoryName});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  late List<DiagnosticQuestion> _questions;
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<String, int> _normScores = {};
  final Map<String, int> _normTotals = {};
  final List<DiagnosticRecommendation> _currentRecommendations = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final category = DocumentCategory.values.firstWhere(
      (c) => c.name == widget.categoryName,
      orElse: () => DocumentCategory.seguridad,
    );
    _questions = buildDiagnosticSession(
      category,
      sessionSalt: DateTime.now().microsecondsSinceEpoch & 0x7fffffff,
    );

    // Inicializar contadores por norma
    for (var q in _questions) {
      _normTotals[q.norm] = (_normTotals[q.norm] ?? 0) + 1;
      _normScores[q.norm] = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentIndex > 0) {
      HapticFeedback.selectionClick();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _answer(bool yes) {
    HapticFeedback.lightImpact();
    final question = _questions[_currentIndex];

    if (yes) {
      _normScores[question.norm] = (_normScores[question.norm] ?? 0) + 1;
    } else {
      final exists = _currentRecommendations.any(
        (recommendation) =>
            recommendation.norm == question.norm &&
            recommendation.advice == question.advice,
      );

      if (!exists) {
        _currentRecommendations.add(
          DiagnosticRecommendation(
            norm: question.norm,
            topic: question.topic,
            advice: question.advice,
          ),
        );
      }
    }

    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
      setState(() {
        _currentIndex++;
      });
    } else {
      // Calcular cumplimiento por norma
      final Map<String, double> normCompliance = {};
      _normTotals.forEach((norm, total) {
        final score = _normScores[norm] ?? 0;
        normCompliance[norm] = score / total;
      });

      final totalScore = _normScores.values.fold(0, (a, b) => a + b);

      final result = DiagnosticResult(
        score: totalScore,
        totalQuestions: _questions.length,
        recommendations: _currentRecommendations,
        category: _questions.first.category,
        normCompliance: normCompliance,
      );
      context.pushReplacement('/diagnostic-result', extra: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('No hay preguntas para esta categoría.'),
        ),
      );
    }

    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_questions.first.category.displayName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _goBack,
              )
            : null,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Header de Progreso Premium
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_currentIndex + 1}/${_questions.length}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evaluación dinámica de hoy',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mostramos una combinación de preguntas clave para evitar resultados repetitivos y enfocarnos en hallazgos prioritarios.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          opacity: 0.05,
                          blur: 10,
                          borderRadius: BorderRadius.circular(28),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    question.norm,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ).animate().scale(delay: 200.ms),
                                const SizedBox(height: 24),
                                Text(
                                  question.question,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ).animate().fade(delay: 400.ms),
                                const SizedBox(height: 20),
                                Text(
                                  question.topic,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ).animate().fade(delay: 500.ms),
                                const SizedBox(height: 8),
                                Text(
                                  diagnosticNormTitle(question.norm),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ).animate().fade(delay: 550.ms),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _answer(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: const Text(
                          'NO',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _answer(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        child: const Text(
                          'SÍ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ).animate().fade(delay: 700.ms).slideY(begin: 0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
