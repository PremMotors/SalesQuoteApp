class CustomerQuote {
  final int? custID;
  final String? custName;
  final String? phoneNo;
  final String? city;
  final String? custType;
  final String? model;
  final String? variant;
  final String? modelWithType;
  final String? colour;
  final String? profession;
  final double? exShowroomPrice;
  final String? corporateName;
  final String? deptName;

  CustomerQuote({
    this.custID,
    this.custName,
    this.phoneNo,
    this.city,
    this.custType,
    this.model,
    this.variant,
    this.modelWithType,
    this.colour,
    this.profession,
    this.exShowroomPrice,
    this.corporateName,
    this.deptName,
  });

  factory CustomerQuote.fromJson(Map<String, dynamic> json) {
    return CustomerQuote(
      custID: json["custID"],
      custName: json["custName"],
      phoneNo: json["phoneNo"],
      city: json["city"],
      custType: json["custType"],
      model: json["model"],
      variant: json["variant"],
      modelWithType: json["model_with_Type"],
      colour: json["colour"],
      profession: json["profession"],
      exShowroomPrice: (json["exShowroomPrice"] as num?)?.toDouble(),
      corporateName: json["corporateName"],
      deptName: json["deptName"],
    );
  }
}