class WinchOrderRateModel {
  String? message;
  Data? data;

  WinchOrderRateModel({this.message, this.data});

  WinchOrderRateModel.fromJson(Map<String, dynamic> json) {
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
  Order? order;

  Data({this.order});

  Data.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (order != null) {
      data['order'] = order!.toJson();
    }
    return data;
  }
}

class Order {
  int? id;
  String? status;
  String? paymentMethod;
  UserCar? userCar;
  var servicesPrice;
  var taxPrice;
  var total;
  List<Statueses>? statueses;
  var rate;
  double? fromLat;
  String? fromLon;
  String? toLat;
  String? toLon;
  String? fromText;
  String? toText;
  String? distanceInMeters;
  String? durationInMinutes;
  Brand? vendor;
  Worker? worker;

  Order(
      {this.id,
      this.status,
      this.paymentMethod,
      this.servicesPrice,
      this.taxPrice,
      this.total,
      this.userCar,
      this.statueses,
      this.rate,
      this.fromLat,
      this.fromLon,
      this.toLat,
      this.toLon,
      this.fromText,
      this.toText,
      this.distanceInMeters,
      this.durationInMinutes,
      this.vendor,
      this.worker});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    paymentMethod = json['payment_method'];
    servicesPrice = json['services_price'];
    taxPrice = json['tax_price'];
    total = json['total'];
    userCar =
        json['userCar'] != null ? UserCar.fromJson(json['userCar']) : null;
    if (json['statueses'] != null) {
      statueses = <Statueses>[];
      json['statueses'].forEach((v) {
        statueses!.add(Statueses.fromJson(v));
      });
    }
    rate = json['rate'];
    fromLat = json['from_lat'];
    fromLon = json['from_lon'];
    toLat = json['to_lat'];
    toLon = json['to_lon'];
    fromText = json['from_text'];
    toText = json['to_text'];
    distanceInMeters = json['distance_in_meters'];
    durationInMinutes = json['duration_in_minutes'];
    vendor = json['vendor'] != null ? Brand.fromJson(json['vendor']) : null;
    worker = json['worker'] != null ? Worker.fromJson(json['worker']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['payment_method'] = paymentMethod;
    data['services_price'] = servicesPrice;
    data['tax_price'] = taxPrice;
    data['total'] = total;
    if (userCar != null) {
      data['userCar'] = userCar!.toJson();
    }
    if (statueses != null) {
      data['statueses'] = statueses!.map((v) => v.toJson()).toList();
    }
    data['rate'] = rate;
    data['from_lat'] = fromLat;
    data['from_lon'] = fromLon;
    data['to_lat'] = toLat;
    data['to_lon'] = toLon;
    data['from_text'] = fromText;
    data['to_text'] = toText;
    data['distance_in_meters'] = distanceInMeters;
    data['duration_in_minutes'] = durationInMinutes;
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    if (worker != null) {
      data['worker'] = worker!.toJson();
    }
    return data;
  }
}

class UserCar {
  int? id;
  bool? isDefault;
  Car? car;

  UserCar({this.id, this.isDefault, this.car});

  UserCar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isDefault = json['is_default'];
    car = json['car'] != null ? Car.fromJson(json['car']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['is_default'] = isDefault;
    if (car != null) {
      data['car'] = car!.toJson();
    }
    return data;
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
  Brand? brand;

  Model({this.id, this.name, this.brand});

  Model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
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

class Brand {
  int? id;
  String? name;

  Brand({this.id, this.name});

  Brand.fromJson(Map<String, dynamic> json) {
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

class Statueses {
  String? status;
  String? time;

  Statueses({this.status, this.time});

  Statueses.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['time'] = time;
    return data;
  }
}

class Worker {
  int? id;
  String? name;
  String? phone;

  Worker({this.id, this.name, this.phone});

  Worker.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    return data;
  }
}
