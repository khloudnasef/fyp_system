class SupervisorModel {
  final String supervisorContact;
  final String supervisorEmail;
  final String supervisorId;
  final String supervisorName;
  final Map<String, Map<String, String>> timetable;

  SupervisorModel({
    required this.supervisorContact,
    required this.supervisorEmail,
    required this.supervisorId,
    required this.supervisorName,
    required this.timetable,
  });

  Map<String, dynamic> toJson() => {
        'supervisorContact': supervisorContact,
        'supervisorEmail': supervisorEmail,
        'supervisorId': supervisorId,
        'supervisorName': supervisorName,
        'timetable': Map<String, dynamic>.from(timetable).map((key, value) {
          return MapEntry(key, Map<String, dynamic>.from(value));
        }),
      };

  static SupervisorModel fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> timetableJson = json['timetable'];
    Map<String, Map<String, String>> timetable = {};

    timetableJson.forEach((key, value) {
      Map<String, String> innerMap = {};
      value.forEach((innerKey, innerValue) {
        innerMap[innerKey] = innerValue.toString();
      });
      timetable[key] = innerMap;
    });

    return SupervisorModel(
      supervisorContact: json['supervisorContact'],
      supervisorEmail: json['supervisorEmail'],
      supervisorId: json['supervisorId'],
      supervisorName: json['supervisorName'],
      timetable: timetable,
    );
  }
}
