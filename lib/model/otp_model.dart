class OtpModel {
  String? message;
  Data? data;

  OtpModel({this.message, this.data});

  OtpModel.fromJson(Map<String, dynamic> json) {
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
  bool? success;
  int? otpForTesting;

  Data({this.success, this.otpForTesting});

  Data.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    otpForTesting = json['otp_for_testing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['otp_for_testing'] = otpForTesting;
    return data;
  }
}
