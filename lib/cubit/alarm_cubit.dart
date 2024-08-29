import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

part 'alarm_state.dart';

const FlutterSecureStorage fss = FlutterSecureStorage();

class AlarmCubit extends Cubit<AlarmState> {
  AlarmCubit() : super(AlarmInitial());

  Future<void> addalarm(AlarmModel alarm) async {
    // await fss.deleteAll();
    log("First ${alarm.name}");
    final existingList = await fss.read(key: "list");
    if (existingList == null) {
      List<Map<String, dynamic>> alarmList = [alarm.toMap()];
      String alarmJson = jsonEncode(alarmList);
      await fss.write(key: "list", value: alarmJson);
      emit(alarm);
    } else {
      final List<dynamic> oldList = jsonDecode(existingList);
      final last = oldList.lastWhere(
        (e) => e['name'].toString().split('-')[0] == alarm.name,
      );
      log("Only Last $last");
      if (last != null) {
        final List<String> splitName = last['name'].toString().split("-");
        if (splitName.length > 1 && int.tryParse(splitName[1]) != null) {
          alarm = AlarmModel(
            name: '${alarm.name}-${(int.parse(splitName[1]) + 1).toString()}',
            time: alarm.time,
            dateTime: alarm.dateTime,
            isActive: alarm.isActive,
          );
        } else {
          alarm = AlarmModel(
              name: '${alarm.name}-1',
              time: alarm.time,
              dateTime: alarm.dateTime,
              isActive: true);
        }
      }

      oldList.add(alarm.toMap());
      String alarmJson = jsonEncode(oldList);
      await fss.write(key: "list", value: alarmJson);
      emit(alarm);
    }
  }

  Future<List<AlarmModel?>>? getall() async {
    final existingList = await fss.read(key: "list");
    if (existingList != null) {
      final List<dynamic> decode = jsonDecode(existingList);
      final List<AlarmModel> list =
          decode.map((e) => AlarmModel.fromMap(e)).toList();
      return list;
    }
    return [];
  }

  Future<void> deleteAlarm(String alarmName) async {
    final String? existingList = await fss.read(key: "list");
    final List<dynamic> decode = jsonDecode(existingList ?? '[]');
    final List<AlarmModel> list = decode.map((e) {
      return AlarmModel.fromMap(e);
    }).toList();
    list.removeWhere((e) => e.name == alarmName);
    final alarmString = list.map((e) => e.toMap()).toList();
    final alarmJson = jsonEncode(alarmString);
    await fss.write(key: "list", value: alarmJson);
    emit(AlarmModel(name: alarmName, time: ""));
  }

  Future<void> clearAll() async {
    await fss.deleteAll();
  }
}
