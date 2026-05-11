class TiresBrandsModel {
  String? message;
  Data? data;

  TiresBrandsModel({this.message, this.data});

  TiresBrandsModel.fromJson(Map<String, dynamic> json) {
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
  List<TireBrands>? tireBrands;

  Data({this.tireBrands});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['tireBrands'] != null) {
      tireBrands = <TireBrands>[];
      json['tireBrands'].forEach((v) {
        tireBrands!.add(TireBrands.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tireBrands != null) {
      data['tireBrands'] = tireBrands!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TireBrands {
  int? id;
  String? name;

  TireBrands({this.id, this.name});

  TireBrands.fromJson(Map<String, dynamic> json) {
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
