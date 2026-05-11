class CarModel {
  String? message;
  Data? data;

  CarModel({this.message, this.data});

  CarModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class Data {
  List<UserCars>? userCars;

  Data({this.userCars});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['userCars'] != null) {
      userCars =
          (json['userCars'] as List).map((v) => UserCars.fromJson(v)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userCars': userCars?.map((v) => v.toJson()).toList(),
    };
  }
}

class UserCars {
  int? id;
  bool? isDefault;
  Car? car;

  UserCars({this.id, this.isDefault, this.car});

  UserCars.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isDefault = json['is_default'];
    car = json['car'] != null ? Car.fromJson(json['car']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_default': isDefault,
      'car': car?.toJson(),
    };
  }
}

class Car {
  int? id;
  String? year;
  String? engine;
  Model? model;

  Car({this.id, this.year, this.engine, this.model});

  Car.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    year = json['year'];
    engine = json['engine'];
    model = json['model'] != null ? Model.fromJson(json['model']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'engine': engine,
      'model': model?.toJson(),
    };
  }
}

class Model {
  int? id;
  String? name;
  Brand? brand;

  Model({this.id, this.name, this.brand});

  Model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand?.toJson(),
    };
  }
}

class Brand {
  int? id;
  String? name;

  Brand({this.id, this.name});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
