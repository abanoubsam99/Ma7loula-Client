class SliderData {
  String? message;
  StartUpSlides? startUpSlides;

  SliderData({this.startUpSlides, this.message});

  SliderData.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    startUpSlides =
        json['data'] != null ? StartUpSlides.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (startUpSlides != null) {
      data['data'] = startUpSlides!.toJson();
    }
    return data;
  }
}

class StartUpSlides {
  List<Registration>? startUpSlides;

  StartUpSlides({this.startUpSlides});

  StartUpSlides.fromJson(Map<String, dynamic> json) {
    if (json['sliders'] != null) {
      startUpSlides = <Registration>[];
      json['sliders'].forEach((v) {
        startUpSlides!.add(Registration.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (startUpSlides != null) {
      data['sliders'] = startUpSlides!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Registration {
  String? pictureModel;
  String? title;
  String? description;

  Registration({this.pictureModel, this.title, this.description});

  Registration.fromJson(Map<String, dynamic> json) {
    pictureModel = json['image'];
    title = json['text'];
    description = json['subtext'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = pictureModel;
    data['text'] = title;
    data['subtext'] = description;
    return data;
  }
}
