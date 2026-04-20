import 'dart:math';

import 'package:myapp/src/features/dashboard/document_model.dart';

class DiagnosticQuestion {
  final String id;
  final String question;
  final String advice;
  final String norm;
  final String topic;
  final DocumentCategory category;

  const DiagnosticQuestion({
    required this.id,
    required this.question,
    required this.advice,
    required this.norm,
    required this.topic,
    required this.category,
  });
}

class DiagnosticRecommendation {
  final String norm;
  final String topic;
  final String advice;

  const DiagnosticRecommendation({
    required this.norm,
    required this.topic,
    required this.advice,
  });
}

class NormReference {
  final String code;
  final String title;
  final String focus;

  const NormReference({
    required this.code,
    required this.title,
    required this.focus,
  });
}

class DiagnosticResult {
  final int score;
  final int totalQuestions;
  final List<DiagnosticRecommendation> recommendations;
  final DocumentCategory category;
  final Map<String, double> normCompliance;

  const DiagnosticResult({
    required this.score,
    required this.totalQuestions,
    required this.recommendations,
    required this.category,
    required this.normCompliance,
  });

  double get percentage => totalQuestions == 0 ? 0 : (score / totalQuestions) * 100;

  String get riskLevel {
    if (percentage >= 80) return 'Bajo';
    if (percentage >= 50) return 'Medio';
    return 'Alto';
  }

  List<MapEntry<String, double>> get prioritizedNorms {
    final entries = normCompliance.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return entries;
  }
}

const int diagnosticSessionSize = 8;

const Map<String, NormReference> diagnosticNorms = {
  'NOM-001': NormReference(
    code: 'NOM-001',
    title: 'Edificios, locales e instalaciones seguras',
    focus: 'Orden, transito, pisos, escaleras y condiciones fisicas seguras.',
  ),
  'NOM-002': NormReference(
    code: 'NOM-002',
    title: 'Prevención y protección contra incendios',
    focus: 'Clasificación de riesgo, extintores, rutas y brigadas.',
  ),
  'NOM-004': NormReference(
    code: 'NOM-004',
    title: 'Seguridad en maquinaria y equipo',
    focus: 'Guardas, bloqueos y procedimientos seguros de operacion.',
  ),
  'NOM-005': NormReference(
    code: 'NOM-005',
    title: 'Manejo de sustancias quimicas peligrosas',
    focus: 'Controles, hojas de seguridad y respuesta a emergencias.',
  ),
  'NOM-006': NormReference(
    code: 'NOM-006',
    title: 'Manejo y almacenamiento de materiales',
    focus: 'Estibas, cargas y transito interno de materiales.',
  ),
  'NOM-009': NormReference(
    code: 'NOM-009',
    title: 'Trabajos en altura',
    focus: 'Permisos, lineas de vida, anclajes e inspecciones previas.',
  ),
  'NOM-010': NormReference(
    code: 'NOM-010',
    title: 'Agentes quimicos contaminantes',
    focus: 'Identificacion, medicion y control de exposiciones.',
  ),
  'NOM-011': NormReference(
    code: 'NOM-011',
    title: 'Ruido en los centros de trabajo',
    focus: 'Monitoreo, protección auditiva y conservación de la audición.',
  ),
  'NOM-015': NormReference(
    code: 'NOM-015',
    title: 'Condiciones termicas elevadas o abatidas',
    focus: 'Proteccion frente a calor, frio, hidratacion y pausas.',
  ),
  'NOM-017': NormReference(
    code: 'NOM-017',
    title: 'Equipo de protección personal',
    focus: 'Análisis por puesto, selección, entrega y uso de EPP.',
  ),
  'NOM-019': NormReference(
    code: 'NOM-019',
    title: 'Comisiones de seguridad e higiene',
    focus: 'Integracion, recorridos y seguimiento a hallazgos.',
  ),
  'NOM-025': NormReference(
    code: 'NOM-025',
    title: 'Iluminacion en centros de trabajo',
    focus: 'Niveles adecuados, mantenimiento y reduccion de fatiga visual.',
  ),
  'NOM-026': NormReference(
    code: 'NOM-026',
    title: 'Senales de seguridad e higiene',
    focus: 'Colores, avisos, identificacion de riesgos y tuberias.',
  ),
  'NOM-030': NormReference(
    code: 'NOM-030',
    title: 'Servicios preventivos de seguridad y salud',
    focus: 'Diagnostico, programa anual y responsables designados.',
  ),
  'NOM-033': NormReference(
    code: 'NOM-033',
    title: 'Espacios confinados',
    focus: 'Permisos, rescate, monitoreo atmosferico y vigilancia.',
  ),
  'NOM-035': NormReference(
    code: 'NOM-035',
    title: 'Factores de riesgo psicosocial',
    focus: 'Politica, evaluaciones y mecanismos de queja.',
  ),
  'NOM-036': NormReference(
    code: 'NOM-036',
    title: 'Factores de riesgo ergonomico',
    focus: 'Levantamiento manual, ayudas mecanicas y pausas activas.',
  ),
  'NOM-018': NormReference(
    code: 'NOM-018',
    title: 'Identificacion y comunicacion de peligros por sustancias quimicas (GHS)',
    focus: 'Etiquetado, hojas de datos de seguridad, inventarios y capacitacion.',
  ),
  'NOM-029': NormReference(
    code: 'NOM-029',
    title: 'Mantenimiento de instalaciones electricas (seguridad)',
    focus: 'Procedimientos seguros, energia cero, EPP y control de riesgos electricos.',
  ),
  'NOM-031': NormReference(
    code: 'NOM-031',
    title: 'Seguridad y salud en obras de construccion',
    focus: 'Orden y limpieza, accesos, trabajos en altura y control de riesgos en obra.',
  ),
  'NOM-037': NormReference(
    code: 'NOM-037',
    title: 'Teletrabajo (condiciones de seguridad y salud)',
    focus: 'Politicas, ergonomia, desconexion y seguimiento de condiciones de trabajo remoto.',
  ),
};

final List<DiagnosticQuestion> diagnosticQuestions = [
  const DiagnosticQuestion(
    id: 'n1-1',
    question: 'Las escaleras, rampas y pasillos cuentan con condiciones seguras y libres de obstruccion?',
    advice: 'Verifique superficies, pendientes, pasamanos y rutina de orden para evitar caidas y tropiezos.',
    norm: 'NOM-001',
    topic: 'Transito y circulacion segura',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n1-2',
    question: 'Las areas de almacenamiento y operacion estan delimitadas y con flujo peatonal claro?',
    advice: 'Delimite zonas y trayectos para separar peatones, materiales y equipos moviles.',
    norm: 'NOM-001',
    topic: 'Delimitacion de areas',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n2-1',
    question: 'La clasificación de riesgo de incendio del centro de trabajo está definida y documentada?',
    advice: 'Actualice la clasificación de riesgo para asegurar el equipo y plan de respuesta adecuados.',
    norm: 'NOM-002',
    topic: 'Riesgo de incendio',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n2-2',
    question: 'Los extintores tienen mantenimiento vigente y estan visibles, senalizados y sin obstaculos?',
    advice: 'Revise mantenimiento, ubicación y accesibilidad de extintores en cada área crítica.',
    norm: 'NOM-002',
    topic: 'Extintores y control inicial',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n2-3',
    question: 'Las rutas de evacuacion y salidas de emergencia se mantienen identificadas y funcionales?',
    advice: 'Asegure senales visibles, alumbrado de emergencia y salidas libres durante toda la jornada.',
    norm: 'NOM-002',
    topic: 'Evacuacion y emergencia',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n4-1',
    question: 'La maquinaria cuenta con guardas, dispositivos de seguridad y puntos de paro identificados?',
    advice: 'Instale y mantenga guardas efectivas para evitar atrapamientos, cortes y contactos peligrosos.',
    norm: 'NOM-004',
    topic: 'Guardas y dispositivos',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n4-2',
    question: 'Existen procedimientos de bloqueo y etiquetado para mantenimiento o ajustes de maquinaria?',
    advice: 'Implemente procedimientos de energia cero para intervenir maquinaria de forma segura.',
    norm: 'NOM-004',
    topic: 'Bloqueo y etiquetado',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n17-1',
    question: 'Se ha realizado el analisis por puesto para definir el EPP requerido?',
    advice: 'Actualice el analisis de riesgos por puesto y vinculelo con la matriz de EPP.',
    norm: 'NOM-017',
    topic: 'Seleccion de EPP',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n17-2',
    question: 'Existe evidencia de entrega, capacitacion y reposicion del EPP al personal?',
    advice: 'Documente entrega, uso correcto y reposicion oportuna de cada equipo de proteccion personal.',
    norm: 'NOM-017',
    topic: 'Entrega y seguimiento de EPP',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n26-1',
    question: 'La senalizacion preventiva, obligatoria y de emergencia es clara y consistente en sitio?',
    advice: 'Refuerce colores, formas y ubicaciones de senales para facilitar respuesta inmediata.',
    norm: 'NOM-026',
    topic: 'Senalizacion visible',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n6-s1',
    question: 'En el manejo y almacenamiento de materiales, se mantienen estibas estables y rutas despejadas para evitar golpes y caidas?',
    advice: 'Asegure estibas estables, limites de altura, pasillos libres y control de transito interno de materiales.',
    norm: 'NOM-006',
    topic: 'Almacenamiento y transito de materiales',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n5-s1',
    question: 'Las sustancias quimicas peligrosas se almacenan con contencion, compatibilidad y procedimientos de manejo seguro?',
    advice: 'Revise contencion, compatibilidad, ventilacion, EPP y procedimientos para evitar exposiciones y emergencias.',
    norm: 'NOM-005',
    topic: 'Sustancias quimicas (controles)',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n29-s1',
    question: 'Se controla el riesgo electrico en mantenimiento mediante bloqueo/etiquetado, verificacion de ausencia de energia y EPP?',
    advice: 'Aplique procedimientos de energia cero, herramientas adecuadas y verificacion previa antes de intervenir instalaciones electricas.',
    norm: 'NOM-029',
    topic: 'Riesgo electrico',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n31-s1',
    question: 'En obra, se controlan riesgos criticos como caidas de altura, excavaciones y orden/limpieza con supervision efectiva?',
    advice: 'Refuerce controles en obra: protecciones colectivas, accesos, senalizacion, orden/limpieza y supervision de frentes de trabajo.',
    norm: 'NOM-031',
    topic: 'Seguridad en obra',
    category: DocumentCategory.seguridad,
  ),
  const DiagnosticQuestion(
    id: 'n10-1',
    question: 'Se identifican y controlan agentes químicos que puedan representar exposición al personal?',
    advice: 'Revise inventario, exposiciones y controles de ingenieria o administrativos para sustancias peligrosas.',
    norm: 'NOM-010',
    topic: 'Exposicion a quimicos',
    category: DocumentCategory.salud,
  ),
  const DiagnosticQuestion(
    id: 'n10-2',
    question: 'El personal conoce las hojas de datos de seguridad y las medidas de respuesta ante exposición?',
    advice: 'Capacite sobre hojas de seguridad, rutas de contacto y respuesta inmediata ante incidentes.',
    norm: 'NOM-010',
    topic: 'Hojas de seguridad',
    category: DocumentCategory.salud,
  ),
  const DiagnosticQuestion(
    id: 'n18-1',
    question: 'Las sustancias quimicas cuentan con etiqueta y comunicacion de peligros conforme al sistema armonizado (GHS)?',
    advice: 'Verifique etiquetado, pictogramas y que el personal comprenda riesgos, EPP y medidas de control.',
    norm: 'NOM-018',
    topic: 'Etiquetado y comunicacion',
    category: DocumentCategory.salud,
  ),
  const DiagnosticQuestion(
    id: 'n11-1',
    question: 'Se han evaluado áreas con ruido y se controla la exposición del personal?',
    advice: 'Mida ruido, establezca controles y refuerce el programa de conservacion auditiva.',
    norm: 'NOM-011',
    topic: 'Ruido ocupacional',
    category: DocumentCategory.salud,
  ),
  const DiagnosticQuestion(
    id: 'n15-1',
    question: 'Existen medidas para prevenir agotamiento por calor o exposición a frío extremo?',
    advice: 'Defina hidratacion, pausas, sombra, ropa adecuada y vigilancia de sintomas por estres termico.',
    norm: 'NOM-015',
    topic: 'Condiciones termicas',
    category: DocumentCategory.salud,
  ),
  const DiagnosticQuestion(
    id: 'n25-1',
    question: 'La iluminación permite trabajar, inspeccionar y desplazarse sin fatiga visual ni zonas de sombra crítica?',
    advice: 'Revise niveles de iluminación, luminarias dañadas y contraste en tareas de precisión.',
    norm: 'NOM-025',
    topic: 'Iluminacion operativa',
    category: DocumentCategory.salud,
  ),
  const DiagnosticQuestion(
    id: 'n35-1',
    question: 'Existe una politica difundida para prevenir factores de riesgo psicosocial y violencia laboral?',
    advice: 'Mantenga visible la politica y los canales de actuacion ante conductas de riesgo psicosocial.',
    norm: 'NOM-035',
    topic: 'Politica psicosocial',
    category: DocumentCategory.salud,
  ),
  const DiagnosticQuestion(
    id: 'n35-2',
    question: 'El centro de trabajo aplica evaluaciones y acciones de seguimiento sobre entorno organizacional?',
    advice: 'Realice evaluaciones y planes de accion que permitan atender hallazgos psicosociales.',
    norm: 'NOM-035',
    topic: 'Evaluación del entorno',
    category: DocumentCategory.salud,
  ),
  const DiagnosticQuestion(
    id: 'n36-1',
    question: 'Se previenen riesgos ergonomicos en levantamiento, arrastre o empuje manual de cargas?',
    advice: 'Implemente limites, ayudas mecanicas y tecnicas seguras para reducir lesiones musculoesqueleticas.',
    norm: 'NOM-036',
    topic: 'Ergonomia y manejo manual',
    category: DocumentCategory.salud,
  ),
  const DiagnosticQuestion(
    id: 'n19-1',
    question: 'La comisión de seguridad e higiene está integrada y con responsabilidades formalmente asignadas?',
    advice: 'Formalice la comisión y asegure roles claros para seguimiento de hallazgos.',
    norm: 'NOM-019',
    topic: 'Comision activa',
    category: DocumentCategory.organizacion,
  ),
  const DiagnosticQuestion(
    id: 'n19-2',
    question: 'Se documentan recorridos y evidencias de verificacion con seguimiento a acciones correctivas?',
    advice: 'Mantenga bitacoras y cierres de acciones para demostrar seguimiento continuo.',
    norm: 'NOM-019',
    topic: 'Recorridos y seguimiento',
    category: DocumentCategory.organizacion,
  ),
  const DiagnosticQuestion(
    id: 'n30-1',
    question: 'Existe un responsable designado para seguridad y salud con funciones definidas?',
    advice: 'Asigne formalmente al responsable y documente sus funciones de prevención y seguimiento.',
    norm: 'NOM-030',
    topic: 'Responsable del sistema',
    category: DocumentCategory.organizacion,
  ),
  const DiagnosticQuestion(
    id: 'n30-2',
    question: 'El programa anual de seguridad y salud incluye prioridades, responsables y fechas de cumplimiento?',
    advice: 'Convierta el diagnóstico en un plan anual con acciones, responsables y fechas verificables.',
    norm: 'NOM-030',
    topic: 'Programa anual',
    category: DocumentCategory.organizacion,
  ),
  const DiagnosticQuestion(
    id: 'n30-3',
    question: 'Se revisan indicadores y hallazgos para actualizar el plan preventivo del centro de trabajo?',
    advice: 'Use indicadores e incidentes para mantener vigente el programa de seguridad y salud.',
    norm: 'NOM-030',
    topic: 'Mejora continua',
    category: DocumentCategory.organizacion,
  ),
  const DiagnosticQuestion(
    id: 'n37-1',
    question: 'Si aplica teletrabajo, se cuenta con politica y lineamientos claros para seguridad, salud y desconexion?',
    advice: 'Defina lineamientos, responsabilidades, ergonomia y un esquema de seguimiento para teletrabajo.',
    norm: 'NOM-037',
    topic: 'Teletrabajo',
    category: DocumentCategory.organizacion,
  ),
  const DiagnosticQuestion(
    id: 'n26-2',
    question: 'Las areas criticas, rutas y equipos de respuesta se comunican con senales estandarizadas?',
    advice: 'Refuerce identificacion visual para que el personal responda con rapidez en situaciones anormales.',
    norm: 'NOM-026',
    topic: 'Comunicacion visual',
    category: DocumentCategory.organizacion,
  ),
  const DiagnosticQuestion(
    id: 'n5-1',
    question: 'Las sustancias quimicas peligrosas se almacenan y manipulan con controles y equipos adecuados?',
    advice: 'Revise contencion, compatibilidad de almacenamiento y procedimientos de manejo seguro.',
    norm: 'NOM-005',
    topic: 'Sustancias peligrosas',
    category: DocumentCategory.especificas,
  ),
  const DiagnosticQuestion(
    id: 'n5-2',
    question: 'El personal conoce que hacer ante derrames, fugas o liberacion accidental de sustancias?',
    advice: 'Capacite y equipe al personal para controlar derrames y activar respuesta a emergencias.',
    norm: 'NOM-005',
    topic: 'Respuesta a derrames',
    category: DocumentCategory.especificas,
  ),
  const DiagnosticQuestion(
    id: 'n6-1',
    question: 'El almacenamiento de materiales mantiene estabilidad, altura segura y acceso controlado?',
    advice: 'Asegure estibas estables, topes, limites de altura y rutas despejadas para manejo interno.',
    norm: 'NOM-006',
    topic: 'Almacenamiento seguro',
    category: DocumentCategory.especificas,
  ),
  const DiagnosticQuestion(
    id: 'n9-1',
    question: 'Los trabajos en altura se realizan con permiso, anclaje y revisión previa del sistema de protección?',
    advice: 'Valide permisos, lineas de vida, anclajes certificados y condiciones del entorno antes de subir.',
    norm: 'NOM-009',
    topic: 'Trabajos en altura',
    category: DocumentCategory.especificas,
  ),
  const DiagnosticQuestion(
    id: 'n9-2',
    question: 'Se inspeccionan arneses, conectores y puntos de anclaje antes de cada uso?',
    advice: 'Implemente inspecciones preuso y retiro inmediato de equipos danados o vencidos.',
    norm: 'NOM-009',
    topic: 'Inspeccion de equipo en altura',
    category: DocumentCategory.especificas,
  ),
  const DiagnosticQuestion(
    id: 'n29-1',
    question: 'Se controla el riesgo electrico en mantenimiento (aislamiento, bloqueo, verificacion de ausencia de energia)?',
    advice: 'Implemente procedimientos, herramientas, EPP y verificacion de energia cero antes de intervenir.',
    norm: 'NOM-029',
    topic: 'Riesgo electrico',
    category: DocumentCategory.especificas,
  ),
  const DiagnosticQuestion(
    id: 'n31-1',
    question: 'En obra, se controlan accesos, orden/limpieza y riesgos criticos como excavaciones y caidas de altura?',
    advice: 'Refuerce controles en obra: accesos, senalizacion, protecciones colectivas y supervision.',
    norm: 'NOM-031',
    topic: 'Seguridad en construccion',
    category: DocumentCategory.especificas,
  ),
  const DiagnosticQuestion(
    id: 'n33-1',
    question: 'Los espacios confinados cuentan con permiso de entrada, monitoreo atmosferico y vigia?',
    advice: 'No ingrese a espacios confinados sin permiso, mediciones y supervision externa constante.',
    norm: 'NOM-033',
    topic: 'Ingreso a espacios confinados',
    category: DocumentCategory.especificas,
  ),
  const DiagnosticQuestion(
    id: 'n33-2',
    question: 'Existe un plan de rescate especifico y equipo disponible para espacios confinados?',
    advice: 'El rescate debe poder ejecutarse de inmediato con personal y equipo previamente definidos.',
    norm: 'NOM-033',
    topic: 'Rescate y emergencia',
    category: DocumentCategory.especificas,
  ),
];

List<DiagnosticQuestion> buildDiagnosticSession(
  DocumentCategory category, {
  int sessionSize = diagnosticSessionSize,
  int? sessionSalt,
}) {
  final seedDate = DateTime.now();
  final ymdSeed =
      category.index + (seedDate.year * 10000) + (seedDate.month * 100) + seedDate.day;
  final salt = sessionSalt ?? 0;
  final random = Random(
    ymdSeed + salt,
  );

  final categoryQuestions =
      diagnosticQuestions.where((question) => question.category == category).toList();
  if (categoryQuestions.length <= sessionSize) {
    categoryQuestions.shuffle(random);
    return categoryQuestions;
  }

  final questionsByNorm = <String, List<DiagnosticQuestion>>{};
  for (final question in categoryQuestions) {
    questionsByNorm.putIfAbsent(question.norm, () => []).add(question);
  }

  // If we have more norms than the session size, rotate norms daily and pick a subset
  // to avoid exceeding the intended session length.
  final normKeys = questionsByNorm.keys.toList()..shuffle(random);
  final selectedNorms = normKeys.take(min(sessionSize, normKeys.length)).toList();

  final sessionQuestions = <DiagnosticQuestion>[];
  final remainingQuestions = <DiagnosticQuestion>[];

  for (final norm in selectedNorms) {
    final questions = questionsByNorm[norm] ?? const <DiagnosticQuestion>[];
    if (questions.isEmpty) continue;

    final shuffled = [...questions]..shuffle(random);
    sessionQuestions.add(shuffled.first);
    if (shuffled.length > 1) remainingQuestions.addAll(shuffled.skip(1));
  }

  remainingQuestions.shuffle(random);
  for (final question in remainingQuestions) {
    if (sessionQuestions.length >= sessionSize) {
      break;
    }
    sessionQuestions.add(question);
  }

  sessionQuestions.shuffle(random);
  return sessionQuestions;
}

bool hasDiagnosticQuestionsForCategory(DocumentCategory category) {
  return diagnosticQuestions.any((question) => question.category == category);
}

String diagnosticNormTitle(String norm) {
  return diagnosticNorms[norm]?.title ?? norm;
}

String diagnosticNormFocus(String norm) {
  return diagnosticNorms[norm]?.focus ?? 'Revise el cumplimiento operativo y documental de esta norma.';
}
