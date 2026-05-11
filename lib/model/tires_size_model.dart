class TiresSizesModel {
  String? message;
  Data? data;

  TiresSizesModel({this.message, this.data});

  TiresSizesModel.fromJson(Map<String, dynamic> json) {
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
  TireSizes? tireSizes;

  Data({this.tireSizes});

  Data.fromJson(Map<String, dynamic> json) {
    tireSizes = json['tireSizes'] != null
        ? new TireSizes.fromJson(json['tireSizes'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tireSizes != null) {
      data['tireSizes'] = this.tireSizes!.toJson();
    }
    return data;
  }
}
// class Data {
//
//   List<TireSizes>? tireSizes;
//
//   Data({this.tireSizes});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     if (json['tireSizes'] != null) {
//       tireSizes = <TireSizes>[];
//       json['tireSizes'].forEach((v) {
//         tireSizes!.add(TireSizes.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (tireSizes != null) {
//       data['tireSizes'] = tireSizes!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
class TireSizes {
  List<int>? widthTireSizes;
  List<int>? heightTireSizes;
  List<String>? length;

  TireSizes({this.widthTireSizes, this.heightTireSizes, this.length});

  TireSizes.fromJson(Map<String, dynamic> json) {
    widthTireSizes = json['width'].cast<int>();
    heightTireSizes = json['height'].cast<int>();
    length = json['length'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['width'] = this.widthTireSizes;
    data['height'] = this.heightTireSizes;
    data['length'] = this.length;
    return data;
  }
}
// class TireSizes {
//   String? height;
//   String? width;
//   String? length;
//
//   TireSizes({this.height, this.width, this.length});
//
//   TireSizes.fromJson(Map<String, dynamic> json) {
//     height = json['height'];
//     width = json['width'];
//     length = json['length'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['height'] = height;
//     data['width'] = width;
//     data['length'] = length;
//     return data;
//   }
// }

