class CalculatePriceModel {
  String? message;
  Data? data;

  CalculatePriceModel({this.message, this.data});

  CalculatePriceModel.fromJson(Map<String, dynamic> json) {
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
  num? price;

  Data({this.price});

  Data.fromJson(Map<String, dynamic> json) {
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    return data;
  }
}
