class YearsModel {
  String? message;
  Data? data;

  YearsModel({this.message, this.data});

  YearsModel.fromJson(Map<String, dynamic> json) {
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
  List<String>? years;

  Data({this.years});

  Data.fromJson(Map<String, dynamic> json) {
    years = json['years'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['years'] = years;
    return data;
  }
}
