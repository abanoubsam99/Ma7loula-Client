class FAQModel {
  Map<String, Zero> data;

  FAQModel({required this.data});

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    Map<String, Zero> parsedData = {};
    json['data'].forEach((key, value) {
      parsedData[key] = Zero.fromJson(value);
    });

    return FAQModel(data: parsedData);
  }
}

class Zero {
  String? question;
  String? answer;

  Zero({this.question, this.answer});

  factory Zero.fromJson(Map<String, dynamic> json) {
    return Zero(
      question: json['question'],
      answer: json['answer'],
    );
  }
}
