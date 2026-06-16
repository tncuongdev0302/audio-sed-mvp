import '../../domain/entities/analysis_result.dart';
import 'sound_event_model.dart';

class CoughTypeAnalysisModel extends CoughTypeAnalysis {
  const CoughTypeAnalysisModel({
    required super.coughType,
    required super.coughTypeVi,
    required super.confidence,
    required super.probabilities,
  });

  factory CoughTypeAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CoughTypeAnalysisModel(
      coughType: json['cough_type'] as String? ?? 'dry',
      coughTypeVi: json['cough_type_vi'] as String? ?? 'Ho khan',
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
      probabilities: (json['probabilities'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cough_type': coughType,
      'cough_type_vi': coughTypeVi,
      'confidence': confidence,
      'probabilities': probabilities,
    };
  }
}

class SinusRiskModel extends SinusRisk {
  const SinusRiskModel({
    required super.percent,
    required super.level,
    required super.label,
  });

  factory SinusRiskModel.fromJson(Map<String, dynamic> json) {
    return SinusRiskModel(
      percent: json['percent'] as int? ?? 0,
      level: json['level'] as String? ?? 'THẤP',
      label: json['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percent': percent,
      'level': level,
      'label': label,
    };
  }
}

class ObstructionModel extends Obstruction {
  const ObstructionModel({
    required super.level,
  });

  factory ObstructionModel.fromJson(Map<String, dynamic> json) {
    return ObstructionModel(
      level: json['level'] as String? ?? 'Thấp',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
    };
  }
}

class TreatmentItemModel extends TreatmentItem {
  const TreatmentItemModel({
    required super.text,
    required super.type,
  });

  factory TreatmentItemModel.fromJson(Map<String, dynamic> json) {
    return TreatmentItemModel(
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
    };
  }
}

class AnalysisResultModel extends AnalysisResult {
  const AnalysisResultModel({
    required super.events,
    required super.hasCough,
    required super.inferenceTimeMs,
    required super.durationSec,
    super.coughTypeAnalysis,
    super.sinusRisk,
    super.obstruction,
    super.treatmentChecklist,
    super.expertAdvice,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return AnalysisResultModel(
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => SoundEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasCough: json['has_cough'] as bool? ?? false,
      inferenceTimeMs: (json['inference_time_ms'] as num? ?? 0.0).toDouble(),
      durationSec: (json['duration_sec'] as num? ?? 0.0).toDouble(),
      coughTypeAnalysis: json['cough_type_analysis'] != null
          ? CoughTypeAnalysisModel.fromJson(
              json['cough_type_analysis'] as Map<String, dynamic>)
          : null,
      sinusRisk: json['sinus_risk'] != null
          ? SinusRiskModel.fromJson(json['sinus_risk'] as Map<String, dynamic>)
          : null,
      obstruction: json['obstruction'] != null
          ? ObstructionModel.fromJson(json['obstruction'] as Map<String, dynamic>)
          : null,
      treatmentChecklist: (json['treatment_checklist'] as List<dynamic>?)
          ?.map((e) => TreatmentItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expertAdvice: json['expert_advice'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => (e as SoundEventModel).toJson()).toList(),
      'has_cough': hasCough,
      'inference_time_ms': inferenceTimeMs,
      'duration_sec': durationSec,
      'cough_type_analysis': coughTypeAnalysis != null
          ? (coughTypeAnalysis as CoughTypeAnalysisModel).toJson()
          : null,
      'sinus_risk': sinusRisk != null
          ? (sinusRisk as SinusRiskModel).toJson()
          : null,
      'obstruction': obstruction != null
          ? (obstruction as ObstructionModel).toJson()
          : null,
      'treatment_checklist': treatmentChecklist
          ?.map((e) => (e as TreatmentItemModel).toJson())
          .toList(),
      'expert_advice': expertAdvice,
    };
  }
}
