import 'package:flutter/material.dart';

class SupervisorTimetable extends StatefulWidget {
  const SupervisorTimetable({Key? key});

  @override
  State<SupervisorTimetable> createState() => _SupervisorTimetableState();
}

class _SupervisorTimetableState extends State<SupervisorTimetable> {
  // The number of hours in a day
  static const int _numberOfHours = 12;

  // The number of days in a week
  static const int _numberOfDays = 7;

  // The times for each hour of the day
  final List<String> _times = [
    '8 AM',
    '9 AM',
    '10 AM',
    '11 AM',
    '12 PM',
    '1 PM',
    '2 PM',
    '3 PM',
    '4 PM',
    '5 PM',
    '6 PM',
    '7 PM',
  ];

  // The days of the week
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // The timetable slots for each day of the week
  List<List<String>> _timetableSlots = List.generate(
      _numberOfDays, (dayIndex) => List.filled(_numberOfHours, ''));

  final List<Map<String, dynamic>> upcomingMeetings = [
    {
      'icon': Icons.calendar_today,
      'title': 'Review Chapter 1',
      'date': 'April 10, 2023, 3:00 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Timetable and Meetings'),
          backgroundColor: Colors.red,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Add Timetable'),
              Tab(text: 'Upcoming Meetings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Add Timetable Tab
            Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        // Column for time slots
                        DataColumn(
                            label: SizedBox(width: 100, child: Text('Time'))),
                        // Columns for days of the week
                        for (final day in _daysOfWeek)
                          DataColumn(
                              label: SizedBox(width: 100, child: Text(day))),
                      ],
                      rows: [
                        // Rows for each hour of the day
                        for (int hour = 0; hour < _numberOfHours; hour++)
                          DataRow(cells: [
                            // Cell for time slot
                            DataCell(
                              SizedBox(
                                width: 100,
                                child: Text(
                                  _times[hour],
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            // Cells for each day of the week
                            for (int day = 0; day < _numberOfDays; day++)
                              DataCell(
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: 'Enter subject',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 4.0,
                                      ),
                                    ),
                                    onChanged: (text) {
                                      setState(() {
                                        _timetableSlots[day][hour] = text;
                                      });
                                    },
                                    controller: TextEditingController(
                                      text: _timetableSlots[day][hour],
                                    ),
                                  ),
                                ),
                              ),
                          ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Upcoming Meetings Tab
            ListView.builder(
                itemCount: upcomingMeetings.length,
                itemBuilder: (context, index) {
                  final meeting = upcomingMeetings[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon and title
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Icon(
                              meeting['icon'],
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meeting['title'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                ' Friday, April 7 2023', // replace with actual date and time
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
