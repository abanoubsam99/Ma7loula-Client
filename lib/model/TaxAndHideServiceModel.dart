class TaxAndHideServiceModel {
  String? message;
  Data? data;

  TaxAndHideServiceModel({this.message, this.data});

  TaxAndHideServiceModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? repairInstalationService;
  int? taxPercentage;

  Data({this.repairInstalationService, this.taxPercentage});

  Data.fromJson(Map<String, dynamic> json) {
    repairInstalationService = json['repair_instalation_service'];
    taxPercentage = json['tax_percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['repair_instalation_service'] = this.repairInstalationService;
    data['tax_percentage'] = this.taxPercentage;
    return data;
  }
}