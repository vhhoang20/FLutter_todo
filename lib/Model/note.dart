class Note {
  int? id;
  String? title;
  String? description;
  String? date;
  String? endTime;

  Note({
    this.id,
    this.title,
    this.description,
    this.date,
    this.endTime,
  });

  Note.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    date = json['date'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['date'] = date;
    data['endTime'] = endTime;
    return data;
  }
}
