// ═══════════════════════════════════════════════════════════════════════════
// FORGE — Response Models (Aligned with Backend spec)
// ═══════════════════════════════════════════════════════════════════════════

class ForgeResponse {
  final bool success;
  final MaterialRecommendation recommendation;
  final List<Alternative> alternatives;
  final StandardsResult standards;
  final FailureAnalysis failure;
  final CostComparison cost;
  final VendorsResult vendors;
  final ConflictWarning conflictWarning;
  final String? ttsAudioBase64;
  final String? ttsLanguage;
  final bool reportAvailable;

  ForgeResponse({
    required this.success,
    required this.recommendation,
    required this.alternatives,
    required this.standards,
    required this.failure,
    required this.cost,
    required this.vendors,
    required this.conflictWarning,
    this.ttsAudioBase64,
    this.ttsLanguage,
    required this.reportAvailable,
  });

  factory ForgeResponse.fromJson(Map<String, dynamic> json) {
    return ForgeResponse(
      success: json['success'] ?? false,
      recommendation: MaterialRecommendation.fromJson(json['recommendation'] ?? {}),
      alternatives: (json['alternatives'] as List<dynamic>?)
              ?.map((a) => Alternative.fromJson(a))
              .toList() ?? [],
      standards: StandardsResult.fromJson(json['standards'] ?? {}),
      failure: FailureAnalysis.fromJson(json['failure'] ?? {}),
      cost: CostComparison.fromJson(json['cost'] ?? {}),
      vendors: VendorsResult.fromJson(json['vendors'] ?? {}),
      conflictWarning: ConflictWarning.fromJson(json['conflict_warning'] ?? {}),
      ttsAudioBase64: json['tts_audio_base64'],
      ttsLanguage: json['tts_language'],
      reportAvailable: json['report_available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'recommendation': recommendation.toJson(),
      'alternatives': alternatives.map((a) => a.toJson()).toList(),
      'standards': standards.toJson(),
      'failure': failure.toJson(),
      'cost': cost.toJson(),
      'vendors': vendors.toJson(),
      'conflict_warning': conflictWarning.toJson(),
      'tts_audio_base64': ttsAudioBase64,
      'tts_language': ttsLanguage,
      'report_available': reportAvailable,
    };
  }

  /// Demo mock data matching the new backend schema exactly
  static ForgeResponse get mock => ForgeResponse(
        success: true,
        recommendation: MaterialRecommendation(
          name: '316 Stainless Steel',
          category: 'Metal',
          explanation: 'Performs well in coastal conditions due to molybdenum content.',
          composition: {'Fe': 68.0, 'Cr': 18.0, 'Ni': 10.0, 'Mo': 3.0},
          properties: {
            'tensile_strength': 9,
            'ductility': 6,
            'corrosion_resistance': 9,
            'malleability': 5,
            'thermal_resistance': 7,
            'density': 6,
            'surface_finish': 'matte',
          },
          grade: 'Grade 316',
        ),
        alternatives: [
          Alternative(
            name: 'Duplex 2205',
            reason: 'Cheaper alternative with similar corrosion resistance',
            costDifference: '₹40/kg cheaper',
          )
        ],
        standards: StandardsResult(
          passed: true,
          standardsChecked: ['IS 6911', 'ASTM A240'],
          details: [
            StandardDetail(standard: 'IS 6911', status: 'PASS', note: 'Meets stainless steel plate specification'),
            StandardDetail(standard: 'ASTM A240', status: 'PASS', note: 'Approved'),
          ],
        ),
        failure: FailureAnalysis(
          riskLevel: 'LOW',
          failureModes: [
            FailureMode(
              type: 'Crevice Corrosion',
              severity: 'LOW',
              description: 'Can occur in tight gaps where oxygen is depleted.',
              prevention: 'Ensure smooth joints and regular cleaning.',
            )
          ],
          overallRecommendation: 'Monitor drainage points annually.',
        ),
        cost: CostComparison(
          comparison: [
            CostTier(
              name: '316 Stainless Steel',
              pricePerKgMin: 320.0,
              pricePerKgMax: 380.0,
              priceDisplay: '₹320 - ₹380/kg',
              tier: 'Premium',
              currency: 'INR',
            ),
            CostTier(
              name: '304 Stainless Steel',
              pricePerKgMin: 220.0,
              pricePerKgMax: 260.0,
              priceDisplay: '₹220 - ₹260/kg',
              tier: 'Mid-Range',
              currency: 'INR',
            ),
          ],
        ),
        vendors: VendorsResult(
          vendors: [
            VendorInfo(
              name: 'Bangalore Steel Traders',
              address: 'Peenya Industrial Area',
              rating: 4.5,
              totalRatings: 234,
              distanceKm: 3.2,
              mapsUrl: 'https://maps.google.com',
              phone: '+91 98XXXXXXXX',
              openNow: true,
              lat: 13.0285,
              lng: 77.5197,
            )
          ],
          searchRadiusKm: 10.0,
        ),
        conflictWarning: ConflictWarning(
          detected: false,
          conflicts: [],
          resolution: null,
        ),
        ttsAudioBase64: null,
        ttsLanguage: 'en-IN',
        reportAvailable: true,
      );
}

class MaterialRecommendation {
  final String name;
  final String category;
  final String explanation;
  final Map<String, dynamic> composition;
  final Map<String, dynamic> properties;
  final String grade;

  MaterialRecommendation({
    required this.name,
    required this.category,
    required this.explanation,
    required this.composition,
    required this.properties,
    required this.grade,
  });

  factory MaterialRecommendation.fromJson(Map<String, dynamic> json) {
    return MaterialRecommendation(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      explanation: json['explanation'] ?? '',
      composition: json['composition'] != null ? Map<String, dynamic>.from(json['composition']) : {},
      properties: json['properties'] != null ? Map<String, dynamic>.from(json['properties']) : {},
      grade: json['grade'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'explanation': explanation,
      'composition': composition,
      'properties': properties,
      'grade': grade,
    };
  }
}

class Alternative {
  final String name;
  final String reason;
  final String costDifference;

  Alternative({required this.name, required this.reason, required this.costDifference});

  factory Alternative.fromJson(Map<String, dynamic> json) {
    return Alternative(
      name: json['name'] ?? '',
      reason: json['reason'] ?? '',
      costDifference: json['cost_difference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reason': reason,
      'cost_difference': costDifference,
    };
  }
}

class StandardsResult {
  final bool passed;
  final List<String> standardsChecked;
  final List<StandardDetail> details;

  StandardsResult({required this.passed, required this.standardsChecked, required this.details});

  factory StandardsResult.fromJson(Map<String, dynamic> json) {
    return StandardsResult(
      passed: json['passed'] ?? false,
      standardsChecked: List<String>.from(json['standards_checked'] ?? []),
      details: (json['details'] as List<dynamic>?)
              ?.map((d) => StandardDetail.fromJson(d))
              .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passed': passed,
      'standards_checked': standardsChecked,
      'details': details.map((d) => d.toJson()).toList(),
    };
  }
}

class StandardDetail {
  final String standard;
  final String status;
  final String note;

  StandardDetail({required this.standard, required this.status, required this.note});

  factory StandardDetail.fromJson(Map<String, dynamic> json) {
    return StandardDetail(
      standard: json['standard'] ?? '',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'standard': standard,
      'status': status,
      'note': note,
    };
  }
}

class FailureAnalysis {
  final String riskLevel;
  final List<FailureMode> failureModes;
  final String overallRecommendation;

  FailureAnalysis({required this.riskLevel, required this.failureModes, required this.overallRecommendation});

  factory FailureAnalysis.fromJson(Map<String, dynamic> json) {
    return FailureAnalysis(
      riskLevel: json['risk_level'] ?? '',
      failureModes: (json['failure_modes'] as List<dynamic>?)
              ?.map((m) => FailureMode.fromJson(m))
              .toList() ?? [],
      overallRecommendation: json['overall_recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'risk_level': riskLevel,
      'failure_modes': failureModes.map((m) => m.toJson()).toList(),
      'overall_recommendation': overallRecommendation,
    };
  }
}

class FailureMode {
  final String type;
  final String severity;
  final String description;
  final String prevention;

  FailureMode({required this.type, required this.severity, required this.description, required this.prevention});

  factory FailureMode.fromJson(Map<String, dynamic> json) {
    return FailureMode(
      type: json['type'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      prevention: json['prevention'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'description': description,
      'prevention': prevention,
    };
  }
}

class CostComparison {
  final List<CostTier> comparison;

  CostComparison({required this.comparison});

  factory CostComparison.fromJson(Map<String, dynamic> json) {
    return CostComparison(
      comparison: (json['comparison'] as List<dynamic>?)
              ?.map((t) => CostTier.fromJson(t))
              .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comparison': comparison.map((c) => c.toJson()).toList(),
    };
  }
}

class CostTier {
  final String name;
  final double pricePerKgMin;
  final double pricePerKgMax;
  final String priceDisplay;
  final String tier;
  final String currency;

  CostTier({
    required this.name,
    required this.pricePerKgMin,
    required this.pricePerKgMax,
    required this.priceDisplay,
    required this.tier,
    required this.currency,
  });

  factory CostTier.fromJson(Map<String, dynamic> json) {
    return CostTier(
      name: json['name'] ?? '',
      pricePerKgMin: (json['price_per_kg_min'] as num?)?.toDouble() ?? 0,
      pricePerKgMax: (json['price_per_kg_max'] as num?)?.toDouble() ?? 0,
      priceDisplay: json['price_display'] ?? '',
      tier: json['tier'] ?? '',
      currency: json['currency'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price_per_kg_min': pricePerKgMin,
      'price_per_kg_max': pricePerKgMax,
      'price_display': priceDisplay,
      'tier': tier,
      'currency': currency,
    };
  }
}

class VendorsResult {
  final List<VendorInfo> vendors;
  final double searchRadiusKm;

  VendorsResult({required this.vendors, required this.searchRadiusKm});

  factory VendorsResult.fromJson(Map<String, dynamic> json) {
    return VendorsResult(
      vendors: (json['vendors'] as List<dynamic>?)
              ?.map((v) => VendorInfo.fromJson(v))
              .toList() ?? [],
      searchRadiusKm: (json['search_radius_km'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendors': vendors.map((v) => v.toJson()).toList(),
      'search_radius_km': searchRadiusKm,
    };
  }
}

class VendorInfo {
  final String name;
  final String address;
  final double rating;
  final int totalRatings;
  final double distanceKm;
  final String mapsUrl;
  final String phone;
  final bool openNow;
  final double lat;
  final double lng;

  VendorInfo({
    required this.name,
    required this.address,
    required this.rating,
    required this.totalRatings,
    required this.distanceKm,
    required this.mapsUrl,
    required this.phone,
    required this.openNow,
    this.lat = 0,
    this.lng = 0,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalRatings: json['total_ratings'] ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      mapsUrl: json['maps_url'] ?? '',
      phone: json['phone'] ?? '',
      openNow: json['open_now'] ?? false,
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'rating': rating,
      'total_ratings': totalRatings,
      'distance_km': distanceKm,
      'maps_url': mapsUrl,
      'phone': phone,
      'open_now': openNow,
      'lat': lat,
      'lng': lng,
    };
  }
}

class ConflictWarning {
  final bool detected;
  final List<String> conflicts;
  final String? resolution;

  ConflictWarning({required this.detected, required this.conflicts, this.resolution});

  factory ConflictWarning.fromJson(Map<String, dynamic> json) {
    return ConflictWarning(
      detected: json['detected'] ?? false,
      conflicts: List<String>.from(json['conflicts'] ?? []),
      resolution: json['resolution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detected': detected,
      'conflicts': conflicts,
      'resolution': resolution,
    };
  }
}
