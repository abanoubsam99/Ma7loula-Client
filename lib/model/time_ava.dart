class TimesAvai {
  String? message;
  Data? data;

  TimesAvai({this.message, this.data});

  TimesAvai.fromJson(Map<String, dynamic> json) {
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
  String? date;
  List<Slots>? slots;

  Data({this.date, this.slots});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    if (json['slots'] != null) {
      slots = <Slots>[];
      json['slots'].forEach((v) {
        slots!.add(Slots.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Slots {
  String? time;
  bool? isAvailable;

  Slots({this.time, this.isAvailable});

  Slots.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    isAvailable = json['is_available'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['is_available'] = isAvailable;
    return data;
  }
}
