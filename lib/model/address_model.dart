class AddressModel {
  String? message;
  Data? data;

  AddressModel({this.message, this.data});

  AddressModel.fromJson(Map<String, dynamic> json) {
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
  Address? address;

  Data({this.address});

  Data.fromJson(Map<String, dynamic> json) {
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (address != null) {
      data['address'] = address!.toJson();
    }
    return data;
  }
}

class Address {
  int? id;
  String? name;
  var lat;
  var lon;
  String? details;
  bool? isDefault;
  City? city;
  City? state;

  Address(
      {this.id,
      this.name,
      this.lat,
      this.lon,
      this.details,
      this.isDefault,
      this.city,
      this.state});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lat = json['lat'];
    lon = json['lon'];
    details = json['details'];
    isDefault = json['is_default'];
    city = json['city'] != null ? City.fromJson(json['city']) : null;
    state = json['state'] != null ? City.fromJson(json['state']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['lat'] = lat;
    data['lon'] = lon;
    data['details'] = details;
    data['is_default'] = isDefault;
    if (city != null) {
      data['city'] = city!.toJson();
    }
    if (state != null) {
      data['state'] = state!.toJson();
    }
    return data;
  }
}

class City {
  int? id;
  String? name;

  City({this.id, this.name});

  City.fromJson(Map<String, dynamic> json) {
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
