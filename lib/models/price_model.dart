class PriceModel {
  final String modelGroup;
  final String description;
  final String modelCode;
  final String modelWithType;
  final double exShowroom;
  final double insurance1Plus3;
  final double mgABasic;
  final double rtOPermanent;
  final double otherStateRTO;
<<<<<<< HEAD
  final double RTO_Commercial;
  final double RTO_Temporary;
=======
>>>>>>> 3c3e8268674e7fa0c9a0abfba205afc34835c983
  final double EW_Royal_5th_Year;
  final double cCPPlatinum;
  final double EW_Platinum_4th_Year = 0.0;

  PriceModel({
    required this.modelGroup,
    required this.description,
    required this.modelCode,
    required this.modelWithType,
    required this.exShowroom,
    required this.insurance1Plus3,
    required this.mgABasic,
    required this.rtOPermanent,
    required this.otherStateRTO,
<<<<<<< HEAD
    required this.RTO_Commercial,
    required this.RTO_Temporary,
=======
>>>>>>> 3c3e8268674e7fa0c9a0abfba205afc34835c983
    this.EW_Royal_5th_Year = 0.0,
    // this.EW_Platinum_4th_Year = 0.0,
    this.cCPPlatinum = 0.0,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      modelGroup: json['model_Group'] ?? '',
      description: json['description'] ?? '',
      modelCode: json['model_Code'] ?? '',
      modelWithType: json['model_with_Type'] ?? '',
      exShowroom: (json['ex_Showroom'] ?? 0).toDouble(),
      insurance1Plus3: (json['insurance_1Plus3'] ?? 0).toDouble(),
      mgABasic: (json['mgA_Basic'] ?? 0).toDouble(),
      rtOPermanent: (json['rtO_Permanent'] ?? 0).toDouble(),
      otherStateRTO: (json['otherStateRTO'] ?? 0).toDouble(),
<<<<<<< HEAD
      RTO_Temporary: (json['RTO_Temporary'] ?? 0).toDouble(),
      RTO_Commercial: (json['RTO_Commercial'] ?? 0).toDouble(),
=======
>>>>>>> 3c3e8268674e7fa0c9a0abfba205afc34835c983
      EW_Royal_5th_Year: (json['EW_Royal_5th_Year'] ?? 0).toDouble(),
      cCPPlatinum: (json['cCPPlatinum'] ?? 0).toDouble(),
    );
  }
}