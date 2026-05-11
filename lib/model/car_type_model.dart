class CarTypeModel {
  String? message;
  Data? data;

  CarTypeModel({this.message, this.data});

  CarTypeModel.fromJson(Map<String, dynamic> json) {
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
  List<CarBrands>? carBrands;

  Data({this.carBrands});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['carBrands'] != null) {
      carBrands = <CarBrands>[];
      json['carBrands'].forEach((v) {
        carBrands!.add(CarBrands.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (carBrands != null) {
      data['carBrands'] = carBrands!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CarBrands {
  int? id;
  String? name;

  CarBrands({this.id, this.name});

  CarBrands.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarBrands && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
