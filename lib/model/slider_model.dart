class SliderModel {
  String? message;
  Data? data;

  SliderModel({this.message, this.data});

  SliderModel.fromJson(Map<String, dynamic> json) {
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
  List<Sliders>? sliders;

  Data({this.sliders});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['sliders'] != null) {
      sliders = <Sliders>[];
      json['sliders'].forEach((v) {
        sliders!.add(Sliders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sliders != null) {
      data['sliders'] = sliders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Sliders {
  String? image;
  String? clickable;
  String? link;
  int? productId;

  Sliders({this.image, this.clickable, this.link, this.productId});

  Sliders.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    clickable = json['clickable'];
    link = json['link'];
    productId = json['product_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['clickable'] = clickable;
    data['link'] = link;
    data['product_id'] = productId;
    return data;
  }
}
