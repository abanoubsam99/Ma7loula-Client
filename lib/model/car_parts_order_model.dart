class CarPartsOrderModel {
  String? message;
  Data? data;

  CarPartsOrderModel({this.message, this.data});

  CarPartsOrderModel.fromJson(Map<String, dynamic> json) {
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
  String? deliveryTime;
  bool? hasService;
  int? paymentMethod;
  var productsPrice;
  int? servicesPrice;
  int? taxPrice;
  int? deliveryPrice;
  var total;
  Address? address;
  UserCar? userCar;
  List<Products>? products;
  List<Statueses>? statueses;
  var rate;

  Order(
      {this.id,
      this.status,
      this.deliveryTime,
      this.hasService,
      this.paymentMethod,
      this.productsPrice,
      this.servicesPrice,
      this.taxPrice,
      this.deliveryPrice,
      this.total,
      this.address,
      this.userCar,
      this.products,
      this.statueses,
      this.rate});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    deliveryTime = json['delivery_time'];
    hasService = json['has_service'];
    paymentMethod = json['payment_method'];
    productsPrice = json['products_price'];
    servicesPrice = json['services_price'];
    taxPrice = json['tax_price'];
    deliveryPrice = json['delivery_price'];
    total = json['total'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    userCar =
        json['userCar'] != null ? UserCar.fromJson(json['userCar']) : null;
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    if (json['statueses'] != null) {
      statueses = <Statueses>[];
      json['statueses'].forEach((v) {
        statueses!.add(Statueses.fromJson(v));
      });
    }
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['delivery_time'] = deliveryTime;
    data['has_service'] = hasService;
    data['payment_method'] = paymentMethod;
    data['products_price'] = productsPrice;
    data['services_price'] = servicesPrice;
    data['tax_price'] = taxPrice;
    data['delivery_price'] = deliveryPrice;
    data['total'] = total;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (userCar != null) {
      data['userCar'] = userCar!.toJson();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (statueses != null) {
      data['statueses'] = statueses!.map((v) => v.toJson()).toList();
    }
    data['rate'] = rate;
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

class Products {
  int? id;
  String? name;
  var unitPrice;
  int? qty;
  var total;
  Thumbnail? thumbnail;
  City? vendor;

  Products(
      {this.id,
      this.name,
      this.unitPrice,
      this.qty,
      this.total,
      this.thumbnail,
      this.vendor});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    unitPrice = json['unit_price'];
    qty = json['qty'];
    total = json['total'];
    thumbnail = json['thumbnail'] != null
        ? Thumbnail.fromJson(json['thumbnail'])
        : null;
    vendor = json['vendor'] != null ? City.fromJson(json['vendor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['unit_price'] = unitPrice;
    data['qty'] = qty;
    data['total'] = total;
    if (thumbnail != null) {
      data['thumbnail'] = thumbnail!.toJson();
    }
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    return data;
  }
}

class Thumbnail {
  int? id;
  String? url;

  Thumbnail({this.id, this.url});

  Thumbnail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
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
