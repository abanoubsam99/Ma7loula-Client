class MyOrdersModel {
  String? message;
  Pagination? pagination;
  Data? data;

  MyOrdersModel({this.message, this.pagination, this.data});

  MyOrdersModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Pagination {
  int? page;
  int? ofPages;
  int? perPage;
  int? total;

  Pagination({this.page, this.ofPages, this.perPage, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    ofPages = json['ofPages'];
    perPage = json['perPage'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['ofPages'] = ofPages;
    data['perPage'] = perPage;
    data['total'] = total;
    return data;
  }
}

class Data {
  List<Orders>? orders;

  Data({this.orders});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  int? id;
  String? status;
  String? deliveryTime;
  String? fromText;
  String? toText;
  String? myLocText;
  var paymentMethod;
  var productsPrice;
  int? servicesPrice;
  int? taxPrice;
  int? deliveryPrice;
  var total;
  String? createdAt;
  UserCar? userCar;
  List<Products>? products;

  Orders(
      {this.id,
      this.status,
      this.fromText,
      this.myLocText,
      this.toText,
      this.deliveryTime,
      this.paymentMethod,
      this.productsPrice,
      this.servicesPrice,
      this.taxPrice,
      this.deliveryPrice,
      this.total,
      this.createdAt,
      this.userCar,
      this.products});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    fromText = json['from_text'];
    toText = json['to_text'];
    deliveryTime = json['delivery_time'];
    paymentMethod = json['payment_method'];
    productsPrice = json['products_price'];
    servicesPrice = json['services_price'];
    taxPrice = json['tax_price'];
    deliveryPrice = json['delivery_price'];
    total = json['total'];
    createdAt = json['created_at'];
    userCar =
        json['userCar'] != null ? UserCar.fromJson(json['userCar']) : null;
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['from_text'] = fromText;
    data['to_text'] = toText;
    data['delivery_time'] = deliveryTime;
    data['payment_method'] = paymentMethod;
    data['products_price'] = productsPrice;
    data['services_price'] = servicesPrice;
    data['tax_price'] = taxPrice;
    data['delivery_price'] = deliveryPrice;
    data['total'] = total;
    data['created_at'] = createdAt;
    if (userCar != null) {
      data['userCar'] = userCar!.toJson();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
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

class Products {
  int? id;
  String? name;
  var unitPrice;
  int? qty;
  var total;
  Thumbnail? thumbnail;
  Brand? vendor;

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
    vendor = json['vendor'] != null ? Brand.fromJson(json['vendor']) : null;
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
