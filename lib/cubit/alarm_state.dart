part of 'alarm_cubit.dart';

@immutable
sealed class AlarmState {}

final class AlarmInitial extends AlarmState {}

final class AlarmModel extends AlarmState {
  final String name;
  final String? dateTime;
  final String time;
  final bool? isActive;

  AlarmModel(
      {required this.name, this.dateTime, required this.time, this.isActive});

  AlarmModel fromJson(Map<String, dynamic> json) {
    return AlarmModel(
        name: json['name'],
        dateTime: json['dateTime'],
        time: json['time'],
        isActive: json['isActive']);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateTime': dateTime,
      'time': time,
      'isActive': isActive
    };
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      name: map['name'],
      dateTime: map['dateTime'],
      time: map['time'],
      isActive: map['isActive'],
    );
  }

  @override
  String toString() {
    return {
      'name': name,
      'dateTime': dateTime,
      'time': time,
      'isActive': isActive
    }.toString();
  }
}
