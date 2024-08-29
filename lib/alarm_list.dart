import 'dart:developer';

import 'package:alaram_poc/cubit/alarm_cubit.dart';
// import 'package:alaram_poc/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlaramList extends StatefulWidget {
  const AlaramList({super.key});

  @override
  State<AlaramList> createState() => _AlaramListState();
}

class _AlaramListState extends State<AlaramList> {
  final List<Map<String, dynamic>> alarms = [
    {
      "id": 1,
      "name": "First Alarm",
      "time": "12:00 AM",
      "days": "Monday",
    },
    {
      "id": 2,
      "name": "Second Alarm",
      "time": "12:00 PM",
      "days": "Monday",
    },
    {
      "id": 3,
      "name": "Third Alarm",
      "time": "12:00 PM",
      "days": "Monday",
    },
  ];

  String time = "";

  Future<List<AlarmModel?>?> getlist() async {
    final list = await context.read<AlarmCubit>().getall();
    // log("in Screen $list");
    // log("in Screen ${list as List<dynamic>}");
    return list;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AlarmCubit>().clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alarm List"),
        elevation: 10,
      ),
      body: BlocConsumer<AlarmCubit, AlarmState>(
        listener: (context, state) {
          if (state is AlarmModel) {
            log("is emitted");
            // getlist();
          }
        },
        builder: (context, state) => FutureBuilder<List<AlarmModel?>?>(
          future: context.read<AlarmCubit>().getall(),
          builder: (context, snapshot) =>
              snapshot.hasData == false || snapshot.data?.isEmpty == true
                  ? const Center(
                      child: Text("No Data"),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (itemBuilder, index) {
                        log("in builder");
                        final alarms = snapshot.data;
                        return ListTile(
                          title: Text(
                            alarms?[index]?.name ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(alarms?[index]!.time ?? ""),
                          leading: const Icon(Icons.alarm),
                          trailing: InkWell(
                              onTap: () {
                                context
                                    .read<AlarmCubit>()
                                    .deleteAlarm(alarms![index]!.name);
                              },
                              child: const Icon(
                                Icons.close,
                              )),
                        );
                      }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showTimePicker(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<TimeOfDay> _showTimePicker(BuildContext context) {
    final hour = TimeOfDay.now().hour;
    final minute = TimeOfDay.now().minute;
    return showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: hour, minute: minute))
        .then((val) {
      log("val ${val?.hour} ${val?.minute}");
      final state = context.read<AlarmCubit>();
      state.addalarm(AlarmModel(
        time:
            '${val!.hour <= 9 ? "0${val.hour}" : val.hour}:${val.minute <= 9 ? "0${val.minute}" : val.minute}',
        dateTime: DateTime.now().toIso8601String(),
        name: "Alarm",
        isActive: true,
      ));
      return val;
    });
  }

  Future<void> showbottomsheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      // backgroundColor: Colors.red,
      builder: (BuildContext context) {
        return Container(
          height: 600,
          width: double.infinity,
          decoration: const BoxDecoration(),
          child: Center(
            child: ElevatedButton(
                onPressed: () async {
                  await _showTimePicker(context);
                },
                child: const Text("Add Alarm")),
          ),
        );
      },
    );
  }
}
