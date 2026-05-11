// // import 'package:city_crepe/model/address.dart';
//
// class User {
//   int id;
//   String? name;
//   String? email;
//   String? phone;
//   OrderCanceled lastCancel;
//   // List<Address> addresses;
//
//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     // required this.addresses,
//     required this.lastCancel,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       lastCancel: json['last_cancel_order'] == 0
//           ? OrderCanceled.not
//           : OrderCanceled.yup,
//       id: json['id'],
//       name: json['name'],
//       phone: json['phone'],
//       email: json['email'],
//       // addresses: List<Address>.from(
//       //   json['addresses'].map((address) => Address.fromJson(address)),
//       // ),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'last_cancel_order': lastCancel,
//       'id': id,
//       'name': name,
//       'phone': phone,
//       'email': email,
//     };
//   }
// }
//
// enum OrderCanceled { not, yup }

class UserModel {
  String? message;
  Data? data;

  UserModel({this.message, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
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
  User? user;

  Data({this.user});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  var authToken;
  DefaultAddress? defaultAddress;
  DefaultCar? defaultCar;

  User(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.authToken,
      this.defaultAddress,
      this.defaultCar});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    authToken = json['auth_token'];
    defaultAddress = json['default_address'] != null
        ? DefaultAddress.fromJson(json['default_address'])
        : null;
    defaultCar = json['default_car'] != null
        ? DefaultCar.fromJson(json['default_car'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['auth_token'] = authToken;
    if (defaultAddress != null) {
      data['default_address'] = defaultAddress!.toJson();
    }
    if (defaultCar != null) {
      data['default_car'] = defaultCar!.toJson();
    }
    return data;
  }
}

class DefaultAddress {
  int? id;
  String? name;
  var lat;
  var lon;
  String? details;
  bool? isDefault;
  City? city;
  City? state;

  DefaultAddress(
      {this.id,
      this.name,
      this.lat,
      this.lon,
      this.details,
      this.isDefault,
      this.city,
      this.state});

  DefaultAddress.fromJson(Map<String, dynamic> json) {
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

class DefaultCar {
  int? id;
  String? year;
  String? engine;
  Model? model;

  DefaultCar({this.id, this.year, this.engine, this.model});

  DefaultCar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    year = json['year'];
    engine = json['engine'];
    model = json['model'] != null ? Model.fromJson(json['model']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['year'] = year;
    data['engine'] = engine;
    if (model != null) {
      data['model'] = model!.toJson();
    }
    return data;
  }
}

class Model {
  int? id;
  String? name;
  City? brand;

  Model({this.id, this.name, this.brand});

  Model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    brand = json['brand'] != null ? City.fromJson(json['brand']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    return data;
  }
}
