class ExptionsErrorsModel {
  String? message;
  Null? errors;

  ExptionsErrorsModel({this.message, this.errors});

  ExptionsErrorsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    // errors = json['errors'] != null ? new Errors.fromJson(json['errors']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (errors != null) {
      data['errors'] = errors!.toJson();
    }
    return data;
  }
}
