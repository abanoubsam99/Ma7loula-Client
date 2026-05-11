class OrderCancelledModel {
  String? message;
  Data? data;

  OrderCancelledModel({this.message, this.data});

  OrderCancelledModel.fromJson(Map<String, dynamic> json) {
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
  var hasService;
  int? paymentMethod;
  double? productsPrice;
  int? servicesPrice;
  int? taxPrice;
  int? deliveryPrice;
  double? total;
  var address;
  var userCar;
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
    address = json['address'];
    userCar = json['userCar'];
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
    data['address'] = address;
    data['userCar'] = userCar;
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

class Products {
  int? id;
  String? name;
  double? unitPrice;
  int? qty;
  double? total;
  Thumbnail? thumbnail;
  var vendor;

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
    vendor = json['vendor'];
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
    data['vendor'] = vendor;
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
