class WinchOffersModel {
  String? message;
  Data? data;

  WinchOffersModel({this.message, this.data});

  WinchOffersModel.fromJson(Map<String, dynamic> json) {
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
  List<Wokers>? wokers;

  Data({this.wokers});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['wokers'] != null) {
      wokers = <Wokers>[];
      json['wokers'].forEach((v) {
        wokers!.add(Wokers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (wokers != null) {
      data['wokers'] = wokers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Wokers {
  int? id;
  String? name;
  String? phione;
  String? carPlateNumber;
  String? expiresAt;
  Vendor? vendor;

  Wokers(
      {this.id,
      this.name,
      this.phione,
      this.carPlateNumber,
      this.expiresAt,
      this.vendor});

  Wokers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phione = json['phione'];
    carPlateNumber = json['car_plate_number'];
    expiresAt = json['expires_at'];
    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phione'] = phione;
    data['car_plate_number'] = carPlateNumber;
    data['expires_at'] = expiresAt;
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    return data;
  }
}

class Vendor {
  int? id;
  String? name;

  Vendor({this.id, this.name});

  Vendor.fromJson(Map<String, dynamic> json) {
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
