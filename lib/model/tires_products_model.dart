class TiresProductsModel {
  String? message;
  Pagination? pagination;
  Data? data;

  TiresProductsModel({this.message, this.pagination, this.data});

  TiresProductsModel.fromJson(Map<String, dynamic> json) {
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
  List<Tires>? tires;

  Data({this.tires});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['tires'] != null) {
      tires = <Tires>[];
      json['tires'].forEach((v) {
        tires!.add(Tires.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tires != null) {
      data['tires'] = tires!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tires {
  int? id;
  int? qty;
  String? name;
  var description;
  var price;
  var priceBeforeDiscount;
  int? stock;
  String? status;
  Thumbnail? thumbnail;
  List<Attributes>? attributes;
  List<Thumbnail>? images;
  Brand? brand;
  Brand? category;
  Brand? vendor;

  Tires(
      {this.id,
      this.qty,
      this.name,
      this.description,
      this.price,
      this.priceBeforeDiscount,
      this.stock,
      this.status,
      this.thumbnail,
      this.attributes,
      this.images,
      this.brand,
      this.category,
      this.vendor});

  Tires.fromJson(Map<String, dynamic> json) {
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
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(Attributes.fromJson(v));
      });
    }
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
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
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

class Attributes {
  String? name;
  String? value;

  Attributes({this.name, this.value});

  Attributes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
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
