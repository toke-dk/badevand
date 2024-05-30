class DateInfo {
  DateTime date;
  double value;

  DateInfo({required this.date, required this.value});

  factory DateInfo.fromMap(Map<String,dynamic> map) {
    return DateInfo(
      date: DateTime.parse(map["date"].toString()),
      value: double.parse(map["value"].toString())
    );
  }
}