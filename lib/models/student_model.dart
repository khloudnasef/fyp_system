class StudentModel {
  final String projectTitle;
  final String studentEmail;
  final String studentId;
  final String studentName;
  final String supervisorId;
  final String supervisorName;
  final Map<String, Map<String, String>> timetable;

  StudentModel({
    required this.projectTitle,
    required this.studentEmail,
    required this.studentId,
    required this.studentName,
    required this.supervisorId,
    required this.supervisorName,
    required this.timetable,
  });

  Map<String, dynamic> toJson() => {
        'projectTitle': projectTitle,
        'studentEmail': studentEmail,
        'studentId': studentId,
        'studentName': studentName,
        'supervisorId': supervisorId,
        'supervisorName': supervisorName,
        'timetable': Map<String, dynamic>.from(timetable).map((key, value) {
          return MapEntry(key, Map<String, dynamic>.from(value));
        }),
      };

  static StudentModel fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> timetableJson = json['timetable'];
    Map<String, Map<String, String>> timetable = {};

    timetableJson.forEach((key, value) {
      Map<String, String> innerMap = {};
      value.forEach((innerKey, innerValue) {
        innerMap[innerKey] = innerValue.toString();
      });
      timetable[key] = innerMap;
    });

    return StudentModel(
      projectTitle: json['projectTitle'],
      studentEmail: json['studentEmail'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      supervisorId: json['supervisorId'],
      supervisorName: json['supervisorName'],
      timetable: timetable,
    );
  }
}
