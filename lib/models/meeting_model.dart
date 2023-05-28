class MeetingModel {
  final String studentName;
  final String reason;
  final String day;
  final String date;
  final String time;

  MeetingModel({
    required this.studentName,
    required this.reason,
    required this.day,
    required this.date,
    required this.time,
  });

  factory MeetingModel.fromMap(Map<String, dynamic> map) {
    return MeetingModel(
      reason: map['reason'],
      day: map['day'],
      date: map['date'],
      time: map['time'],
      studentName: map['studentName'],
    );
  }
}
