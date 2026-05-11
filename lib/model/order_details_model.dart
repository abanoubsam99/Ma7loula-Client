class OrderRateModel {
  String? message;
  Data? data;

  OrderRateModel({this.message, this.data});

  OrderRateModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
    return map;
  }
}

class Data {
  Order? order;

  Data({this.order});

  Data.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (order != null) map['order'] = order!.toJson();
    return map;
  }
}

class Order {
  int? id;
  String? status;
  String? reason;
  dynamic paymentMethod;
  String? createdAt;
  String? deliveryTime;
  dynamic productsPrice;
  dynamic offered_total;
  dynamic servicesPrice;
  dynamic taxPrice;
  dynamic deliveryPrice;
  dynamic total;

  // Relations
  User? user;
  Address? address;
  UserCar? userCar;
  List<Products>? products;
  List<VendorLines>? vendorLines;
  List<Statueses>? statueses;
  Rate? rate;

  // Extra fields from second model
  var fromLat;
  var fromLon;
  var toLat;
  var toLon;
  String? fromText;
  String? toText;
  String? distanceInMeters;
  String? durationInMinutes;
  Vendor? vendor;
  Worker? worker;

  Order({
    this.id,
    this.status,
    this.reason,
    this.paymentMethod,
    this.offered_total,
    this.createdAt,
    this.deliveryTime,
    this.productsPrice,
    this.servicesPrice,
    this.taxPrice,
    this.deliveryPrice,
    this.total,
    this.user,
    this.address,
    this.vendorLines,
    this.userCar,
    this.products,
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
    this.worker,
  });

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    reason = json['reason'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    deliveryTime = json['delivery_time'];
    productsPrice = json['products_price'];
    servicesPrice = json['services_price'];
    offered_total = json['offered_total'];
    taxPrice = json['tax_price'];

    deliveryPrice = json['delivery_price'];
    total = json['total'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
    userCar = json['userCar'] != null ? UserCar.fromJson(json['userCar']) : null;

    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) => products!.add(Products.fromJson(v)));
    }

    if (json['statueses'] != null) {
      statueses = [];
      json['statueses'].forEach((v) => statueses!.add(Statueses.fromJson(v)));
    }

    rate = json['rate'] is Map<String, dynamic> ? Rate.fromJson(json['rate']) : null;

    fromLat = (json['from_lat'] as num?)?.toDouble();
    fromLon = json['from_lon'];
    toLat = json['to_lat'];
    toLon = json['to_lon'];
    fromText = json['from_text'];
    if (json['vendor_lines'] != null) {
      vendorLines = <VendorLines>[];
      json['vendor_lines'].forEach((v) {
        vendorLines!.add(new VendorLines.fromJson(v));
      });
    }

    toText = json['to_text'];
    distanceInMeters = json['distance_in_meters'];
    durationInMinutes = json['duration_in_minutes'];
    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
    worker = json['worker'] != null ? Worker.fromJson(json['worker']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['status'] = status;
    map['reason'] = reason;
    map['payment_method'] = paymentMethod;
    map['created_at'] = createdAt;
    map['delivery_time'] = deliveryTime;
    map['products_price'] = productsPrice;
    map['services_price'] = servicesPrice;
    map['offered_total'] = offered_total;
    map['tax_price'] = taxPrice;
    map['delivery_price'] = deliveryPrice;
    map['total'] = total;
    if (vendorLines != null) map['vendor_lines'] = vendorLines!.map((v) => v.toJson()).toList();
    if (user != null) map['user'] = user!.toJson();
    if (address != null) map['address'] = address!.toJson();
    if (userCar != null) map['userCar'] = userCar!.toJson();
    if (products != null) map['products'] = products!.map((e) => e.toJson()).toList();
    if (statueses != null) map['statueses'] = statueses!.map((e) => e.toJson()).toList();
    if (rate != null) map['rate'] = rate!.toJson();
    map['from_lat'] = fromLat;
    map['from_lon'] = fromLon;
    map['to_lat'] = toLat;
    map['to_lon'] = toLon;

    map['from_text'] = fromText;
    map['to_text'] = toText;
    map['distance_in_meters'] = distanceInMeters;
    map['duration_in_minutes'] = durationInMinutes;
    if (vendor != null) map['vendor'] = vendor!.toJson();
    if (worker != null) map['worker'] = worker!.toJson();
    return map;
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

class Rate {
  int? products;
  int? services;
  int? worker;
  String? comment;

  Rate({this.products, this.services, this.worker, this.comment});

  Rate.fromJson(Map<String, dynamic> json) {
    products = json['products'];
    services = json['services'];
    worker = json['worker'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['products'] = products;
    data['services'] = services;
    data['worker'] = worker;
    data['comment'] = comment;
    return data;
  }
}


class User {
  int? id;
  String? name;
  String? email;
  String? phone;

  User({this.id, this.name, this.email, this.phone});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;

    return data;
  }
}

class Worker {
  int? id;
  String? name;
  String? phone;
  String? lat;
  String? lon;

  Worker({this.id, this.name, this.phone, this.lat, this.lon});

  Worker.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    return data;
  }
}
class VendorLines {
  int? orderVendorId;
  int? vendorId;
  String? status;
  int? total;
  int? offeredTotal;

  VendorLines(
      {this.orderVendorId,
        this.vendorId,
        this.status,
        this.total,
        this.offeredTotal});

  VendorLines.fromJson(Map<String, dynamic> json) {
    orderVendorId = json['order_vendor_id'];
    vendorId = json['vendor_id'];
    status = json['status'];
    total = json['total'];
    offeredTotal = json['offered_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_vendor_id'] = this.orderVendorId;
    data['vendor_id'] = this.vendorId;
    data['status'] = this.status;
    data['total'] = this.total;
    data['offered_total'] = this.offeredTotal;
    return data;
  }
}