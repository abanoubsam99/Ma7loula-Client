class VoltagesModel {
  String? message;
  Data? data;

  VoltagesModel({this.message, this.data});

  VoltagesModel.fromJson(Map<String, dynamic> json) {
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
  List<String>? batteryVolts;

  Data({this.batteryVolts});

  Data.fromJson(Map<String, dynamic> json) {
    batteryVolts = json['batteryVolts'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['batteryVolts'] = batteryVolts;
    return data;
  }
}
