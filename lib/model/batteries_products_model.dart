class BatteriesProductsModel {
  String? message;
  Pagination? pagination;
  Data? data;

  BatteriesProductsModel({this.message, this.pagination, this.data});

  BatteriesProductsModel.fromJson(Map<String, dynamic> json) {
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
  List<Batteries>? batteries;

  Data({this.batteries});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['batteries'] != null) {
      batteries = <Batteries>[];
      json['batteries'].forEach((v) {
        batteries!.add(Batteries.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (batteries != null) {
      data['batteries'] = batteries!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Batteries {
  int? id;
  int? qty;
  String? name;
  String? description;
  var price;
  var priceBeforeDiscount;
  int? stock;
  String? status;
  Thumbnail? thumbnail;
  List<Thumbnail>? images;
  Brand? brand;
  Brand? category;
  Brand? vendor;

  Batteries(
      {this.id,
      this.name,
      this.qty,
      this.description,
      this.price,
      this.priceBeforeDiscount,
      this.stock,
      this.status,
      this.thumbnail,
      this.images,
      this.brand,
      this.category,
      this.vendor});

  Batteries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    qty = 1;
    name = json['name'];
    description = json['description'];
    price = json['price'];
    priceBeforeDiscount = json['price_before_discount'];
    stock = json['stock'];
    status = json['status'];
    thumbnail = json['thumbnail'] != null
        ? Thumbnail.fromJson(json['thumbnail'])
        : null;
    if (json['images'] != null) {
      images = <Thumbnail>[];
      json['images'].forEach((v) {
        images!.add(Thumbnail.fromJson(v));
      });
    }
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    category =
        json['category'] != null ? Brand.fromJson(json['category']) : null;
    vendor = json['vendor'] != null ? Brand.fromJson(json['vendor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['price_before_discount'] = priceBeforeDiscount;
    data['stock'] = stock;
    data['status'] = status;
    if (thumbnail != null) {
      data['thumbnail'] = thumbnail!.toJson();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
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

class BatteriesProductsModelLocal {
  String? message;
  Pagination? pagination;
  DataLocal? data;

  BatteriesProductsModelLocal({this.message, this.pagination, this.data});

  BatteriesProductsModelLocal.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
    data = json['data'] != null ? DataLocal.fromJson(json['data']) : null;
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

class DataLocal {
  List<Batteries>? batteries;

  DataLocal({this.batteries});

  DataLocal.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      batteries = <Batteries>[];
      json['products'].forEach((v) {
        batteries!.add(Batteries.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (batteries != null) {
      data['products'] = batteries!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
