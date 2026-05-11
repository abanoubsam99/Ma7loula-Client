class TiresTypesModel {
  String? message;
  Data? data;

  TiresTypesModel({this.message, this.data});

  TiresTypesModel.fromJson(Map<String, dynamic> json) {
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
  List<String>? tireTypes;

  Data({this.tireTypes});

  Data.fromJson(Map<String, dynamic> json) {
    tireTypes = json['tireTypes'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tireTypes'] = tireTypes;
    return data;
  }
}
