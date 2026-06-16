import 'package:equatable/equatable.dart';
import 'sound_event.dart';

class CoughTypeAnalysis extends Equatable {
  final String coughType;
  final String coughTypeVi;
  final double confidence;
  final Map<String, double> probabilities;

  const CoughTypeAnalysis({
    required this.coughType,
    required this.coughTypeVi,
    required this.confidence,
    required this.probabilities,
  });

  @override
  List<Object?> get props => [coughType, coughTypeVi, confidence, probabilities];
}

class SinusRisk extends Equatable {
  final int percent;
  final String level;
  final String label;

  const SinusRisk({
    required this.percent,
    required this.level,
    required this.label,
  });

  @override
  List<Object?> get props => [percent, level, label];
}

class Obstruction extends Equatable {
  final String level;

  const Obstruction({
    required this.level,
  });

  @override
  List<Object?> get props => [level];
}

class TreatmentItem extends Equatable {
  final String text;
  final String type;

  const TreatmentItem({
    required this.text,
    required this.type,
  });

  @override
  List<Object?> get props => [text, type];
}

class AnalysisResult extends Equatable {
  final List<SoundEvent> events;
  final bool hasCough;
  final double inferenceTimeMs;
  final double durationSec;
  final CoughTypeAnalysis? coughTypeAnalysis;
  final SinusRisk? sinusRisk;
  final Obstruction? obstruction;
  final List<TreatmentItem>? treatmentChecklist;
  final String? expertAdvice;

  const AnalysisResult({
    required this.events,
    required this.hasCough,
    required this.inferenceTimeMs,
    required this.durationSec,
    this.coughTypeAnalysis,
    this.sinusRisk,
    this.obstruction,
    this.treatmentChecklist,
    this.expertAdvice,
  });

  @override
  List<Object?> get props => [
        events,
        hasCough,
        inferenceTimeMs,
        durationSec,
        coughTypeAnalysis,
        sinusRisk,
        obstruction,
        treatmentChecklist,
        expertAdvice,
      ];
}
