List<String> sortTimeArray(List<String> timeArray) {
  int timeComparator(String time1, String time2) {
    int hour1 = int.parse(time1.split(' ')[0]);
    int hour2 = int.parse(time2.split(' ')[0]);
    bool isAM1 = time1.endsWith('AM');
    bool isAM2 = time2.endsWith('AM');

    if (!isAM1) hour1 += 12;
    if (!isAM2) hour2 += 12;

    if (hour1 < hour2) {
      return -1;
    } else if (hour1 > hour2) {
      return 1;
    } else {
      int minute1 = int.parse(time1.split(' ')[1]);
      int minute2 = int.parse(time2.split(' ')[1]);

      if (minute1 < minute2) {
        return -1;
      } else if (minute1 > minute2) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  timeArray.sort(timeComparator);
  return timeArray;
}
