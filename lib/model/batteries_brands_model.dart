class BrandsModel {
  String? message;
  Data? data;

  BrandsModel({this.message, this.data});

  BrandsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<BatteryBrands>? batteryBrands;

  Data({this.batteryBrands});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['batteryBrands'] != null) {
      batteryBrands = <BatteryBrands>[];
      json['batteryBrands'].forEach((v) {
        batteryBrands!.add(BatteryBrands.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (batteryBrands != null) {
      data['batteryBrands'] = batteryBrands!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BatteryBrands {
  int? id;
  String? name;

  BatteryBrands({this.id, this.name});

  BatteryBrands.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
