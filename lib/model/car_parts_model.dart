class CarPartsModel {
  String? message;
  Data? data;

  CarPartsModel({this.message, this.data});

  CarPartsModel.fromJson(Map<String, dynamic> json) {
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
  List<ProductCategories>? productCategories;

  Data({required this.productCategories});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['productCategories'] != null) {
      productCategories = <ProductCategories>[];
      json['productCategories'].forEach((v) {
        productCategories!.add(ProductCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (productCategories != null) {
      data['productCategories'] =
          productCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductCategories {
  int? id;
  String? name;
  URLImage? image;
  List<SubCategories>? subCategories;

  ProductCategories({this.id, this.name, this.image, this.subCategories});

  ProductCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'] != null ? URLImage.fromJson(json['image']) : null;
    if (json['subCategories'] != null) {
      subCategories = <SubCategories>[];
      json['subCategories'].forEach((v) {
        subCategories!.add(SubCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (image != null) {
      data['image'] = image!.toJson();
    }
    if (subCategories != null) {
      data['subCategories'] = subCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class URLImage {
  int? id;
  String? url;

  URLImage({this.id, this.url});

  URLImage.fromJson(Map<String, dynamic> json) {
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

class SubCategories {
  int? id;
  String? name;
  String? image;

  SubCategories({this.id, this.name, this.image});

  SubCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}
