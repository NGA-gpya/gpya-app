import 'package:myapp/src/features/dashboard/document_model.dart';

class DiagnosticQuestion {
  final String id;
  final String question;
  final String advice;
  final String norm; // Ej: NOM-002, NOM-035
  final DocumentCategory category;

  DiagnosticQuestion({
    required this.id,
    required this.question,
    required this.advice,
    required this.norm,
    required this.category,
  });
}

class DiagnosticResult {
  final int score;
  final int totalQuestions;
  final List<String> recommendations;
  final DocumentCategory category;
  final Map<String, double> normCompliance; // Norma -> Porcentaje (0.0 a 1.0)

  DiagnosticResult({
    required this.score,
    required this.totalQuestions,
    required this.recommendations,
    required this.category,
    required this.normCompliance,
  });

  double get percentage => (score / totalQuestions) * 100;

  String get riskLevel {
    if (percentage >= 80) return 'Bajo';
    if (percentage >= 50) return 'Medio';
    return 'Alto';
  }
}

final List<DiagnosticQuestion> diagnosticQuestions = [
  // --- NOM-001 (Edificios e Instalaciones) ---
  DiagnosticQuestion(
    id: 'n1-1',
    question: '¿Las escaleras, rampas y puentes cuentan con barandales y condiciones de seguridad?',
    advice: 'La NOM-001 exige estructuras seguras para evitar caídas a distintos niveles.',
    norm: 'NOM-001',
    category: DocumentCategory.seguridad,
  ),
  DiagnosticQuestion(
    id: 'n1-2',
    question: '¿Se encuentran delimitadas las áreas de producción, almacenamiento y circulación?',
    advice: 'La delimitación previene accidentes por invasión de zonas de riesgo.',
    norm: 'NOM-001',
    category: DocumentCategory.seguridad,
  ),
  DiagnosticQuestion(
    id: 'n1-3',
    question: '¿Se mantiene el orden y limpieza constante en todas las áreas de trabajo?',
    advice: 'El orden es la base de la prevención; evita tropiezos y agiliza emergencias.',
    norm: 'NOM-001',
    category: DocumentCategory.seguridad,
  ),

  // --- NOM-002 (Protección contra Incendios) ---
  DiagnosticQuestion(
    id: 'n2-1',
    question: '¿Cuenta con la clasificación de riesgo de incendio (Ordinario o Alto)?',
    advice: 'Es el primer paso legal para determinar el equipo contra incendio necesario.',
    norm: 'NOM-002',
    category: DocumentCategory.seguridad,
  ),
  DiagnosticQuestion(
    id: 'n2-2',
    question: '¿Los extintores cuentan con mantenimiento vigente y están libres de obstáculos?',
    advice: 'Un extintor obstruido o vencido es inútil en una emergencia real.',
    norm: 'NOM-002',
    category: DocumentCategory.seguridad,
  ),
  DiagnosticQuestion(
    id: 'n2-3',
    question: '¿Las rutas de evacuación están señalizadas y cuentan con salidas de emergencia?',
    advice: 'La señalización debe ser visible incluso ante falta de energía eléctrica.',
    norm: 'NOM-002',
    category: DocumentCategory.seguridad,
  ),
  DiagnosticQuestion(
    id: 'n2-4',
    question: '¿Existen brigadistas capacitados para combatir incendios y primeros auxilios?',
    advice: 'El personal debe saber cómo actuar antes de que lleguen los bomberos.',
    norm: 'NOM-002',
    category: DocumentCategory.seguridad,
  ),

  // --- NOM-017 (Equipo de Protección Personal) ---
  DiagnosticQuestion(
    id: 'n17-1',
    question: '¿Se ha realizado el análisis de riesgo por puesto para determinar el EPP?',
    advice: 'No se puede dar EPP sin saber exactamente a qué se expone el trabajador.',
    norm: 'NOM-017',
    category: DocumentCategory.seguridad,
  ),
  DiagnosticQuestion(
    id: 'n17-2',
    question: '¿El EPP entregado cuenta con certificado de fabricante o cumplimiento normativo?',
    advice: 'El equipo "patito" no protege y genera responsabilidad legal al patrón.',
    norm: 'NOM-017',
    category: DocumentCategory.seguridad,
  ),
  DiagnosticQuestion(
    id: 'n17-3',
    question: '¿Existe evidencia documental (firmas) de la entrega del EPP a los trabajadores?',
    advice: 'Ante una inspección, si no está firmado, el EPP no se entregó legalmente.',
    norm: 'NOM-017',
    category: DocumentCategory.seguridad,
  ),

  // --- NOM-019 (Comisiones de Seguridad) ---
  DiagnosticQuestion(
    id: 'n19-1',
    question: '¿Está constituida la Comisión de Seguridad e Higiene mediante acta formal?',
    advice: 'Es obligatorio para todos los centros de trabajo tener esta comisión activa.',
    norm: 'NOM-019',
    category: DocumentCategory.organizacion,
  ),
  DiagnosticQuestion(
    id: 'n19-2',
    question: '¿Se realizan y documentan los recorridos de verificación mensuales o trimestrales?',
    advice: 'Los recorridos permiten detectar actos y condiciones inseguras a tiempo.',
    norm: 'NOM-019',
    category: DocumentCategory.organizacion,
  ),

  // --- NOM-030 (Servicios Preventivos) ---
  DiagnosticQuestion(
    id: 'n30-1',
    question: '¿Cuenta con un responsable de seguridad y salud en el trabajo designado?',
    advice: 'Debe haber alguien encargado formalmente de gestionar la prevención.',
    norm: 'NOM-030',
    category: DocumentCategory.organizacion,
  ),
  DiagnosticQuestion(
    id: 'n30-2',
    question: '¿Tiene un diagnóstico integral actualizado de las condiciones de seguridad?',
    advice: 'El diagnóstico es la "radiografía" legal de cumplimiento de la empresa.',
    norm: 'NOM-030',
    category: DocumentCategory.organizacion,
  ),
  DiagnosticQuestion(
    id: 'n30-3',
    question: '¿Cuenta con un Programa Anual de Seguridad y Salud escrito?',
    advice: 'Es el plan maestro donde se calendarizan todas las acciones del año.',
    norm: 'NOM-030',
    category: DocumentCategory.organizacion,
  ),

  // --- NOM-035 (Riesgo Psicosocial) ---
  DiagnosticQuestion(
    id: 'n35-1',
    question: '¿Tiene una Política de Prevención de Riesgos Psicosociales difundida?',
    advice: 'La política es la declaración oficial de la empresa contra la violencia laboral.',
    norm: 'NOM-035',
    category: DocumentCategory.salud,
  ),
  DiagnosticQuestion(
    id: 'n35-2',
    question: '¿Ha aplicado los cuestionarios para identificar factores de riesgo psicosocial?',
    advice: 'Es obligatorio evaluar el entorno organizacional cada dos años.',
    norm: 'NOM-035',
    category: DocumentCategory.salud,
  ),
  DiagnosticQuestion(
    id: 'n35-3',
    question: '¿Cuenta con un mecanismo para recibir quejas de prácticas opuestas al entorno?',
    advice: 'Debe existir un buzón o canal seguro para reportar acoso o malos tratos.',
    norm: 'NOM-035',
    category: DocumentCategory.salud,
  ),

  // --- NOM-009 / 033 (Riesgos Específicos) ---
  DiagnosticQuestion(
    id: 'ne-1',
    question: '¿Cuenta con procedimientos de seguridad para trabajos en alturas o espacios confinados?',
    advice: 'Son actividades de alto riesgo que requieren permisos de trabajo específicos.',
    norm: 'Específicas',
    category: DocumentCategory.especificas,
  ),
  DiagnosticQuestion(
    id: 'ne-2',
    question: '¿Se capacita anualmente al personal en sus procedimientos de seguridad específicos?',
    advice: 'La capacitación (DC-3) es el respaldo legal de que el trabajador es apto.',
    norm: 'Específicas',
    category: DocumentCategory.especificas,
  ),
];
