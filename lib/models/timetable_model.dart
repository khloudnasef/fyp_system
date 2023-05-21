class TimetableModel {
  Map<String, Map<String, String>> days;

  TimetableModel({required this.days});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    days.forEach((key, value) {
      Map<String, String> timeSlots = {};
      value.forEach((time, subject) {
        timeSlots[time] = subject;
      });
      json[key] = timeSlots;
    });
    return json;
  }

  static TimetableModel fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, String>> days = {};
    json.forEach((key, value) {
      Map<String, String> timeSlots = {};
      value.forEach((time, subject) {
        timeSlots[time] = subject;
      });
      days[key] = timeSlots;
    });

    return TimetableModel(days: days);
  }
}
