class Alarm {
  int id;
  DateTime alarmDateTime;
  String title;
  int isPending; // 1 - pending, 0 - not pending

  Alarm({this.alarmDateTime, this.title, this.isPending});

  Alarm.withId({this.id, this.alarmDateTime, this.title, this.isPending});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = id;
    }

    map['title'] = title;
    map['date'] = alarmDateTime.toIso8601String();
    map['isPending'] = isPending;

    return map;
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm.withId(
      id: map['id'],
      title: map['title'],
      alarmDateTime: DateTime.parse(map['date']),
      isPending: map['isPending'],
    );
  }

  @override
  String toString() {
    return '$id $title $alarmDateTime $isPending';
  }
}
