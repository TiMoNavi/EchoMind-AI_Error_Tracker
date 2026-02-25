/// Data models for Model Detail page.

class ModelDetail {
  final String id;
  final String name;
  final String level;
  final String levelLabel;
  final String levelDescription;
  final int predictedGain;
  final List<FunnelLayer> funnelLayers;

  const ModelDetail({
    required this.id,
    required this.name,
    required this.level,
    required this.levelLabel,
    required this.levelDescription,
    required this.predictedGain,
    required this.funnelLayers,
  });

  factory ModelDetail.fromJson(Map<String, dynamic> json) {
    return ModelDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as String,
      levelLabel: json['level_label'] as String,
      levelDescription: json['level_description'] as String,
      predictedGain: json['predicted_gain'] as int,
      funnelLayers: (json['funnel_layers'] as List)
          .map((e) => FunnelLayer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'level_label': levelLabel,
    'level_description': levelDescription,
    'predicted_gain': predictedGain,
    'funnel_layers': funnelLayers.map((e) => e.toJson()).toList(),
  };
}

class FunnelLayer {
  final String label;
  final String level;
  final double widthFraction;
  final bool stuck;

  const FunnelLayer({
    required this.label,
    required this.level,
    required this.widthFraction,
    required this.stuck,
  });

  factory FunnelLayer.fromJson(Map<String, dynamic> json) {
    return FunnelLayer(
      label: json['label'] as String,
      level: json['level'] as String,
      widthFraction: (json['width_fraction'] as num).toDouble(),
      stuck: json['stuck'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'level': level,
    'width_fraction': widthFraction,
    'stuck': stuck,
  };
}
