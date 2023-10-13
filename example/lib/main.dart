// Copyright 2023 Lakshydeep Vikram Sah. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_english_calendar/nepali_english_calendar.dart';

Color red = const Color(0xffDC143C);
Color blue = const Color(0xff003893);
void main() => runApp(const MyApp());

/// MyApp
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    NepaliUtils().language == Language.nepali;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: blue,
          title: const Text("🇳🇵Nepali Calendar🇳🇵"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Text(
                NepaliUtils().language == Language.english ? 'ने' : 'En',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              onPressed: () {
                NepaliUtils().language =
                    NepaliUtils().language == Language.english
                        ? Language.nepali
                        : Language.english;
                setState(() {});
              },
            ),
          ],
        ),
        body: HomePage(
          nepaliUtils: NepaliUtils(NepaliUtils().language == Language.english
              ? Language.english
              : Language.nepali),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final NepaliUtils nepaliUtils;

  const HomePage({super.key, required this.nepaliUtils});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<NepaliDateTime> _selectedDate =
      ValueNotifier(NepaliDateTime.now());

  /// Events
  final List<Event> events = [
    Event(date: NepaliDateTime.now(), eventTitles: ['Today 1', 'Today 2']),
    Event(
        date: NepaliDateTime.now().add(const Duration(days: 30)),
        eventTitles: ['Holiday 1', 'Holiday 2']),
    Event(
        date: NepaliDateTime.now().subtract(const Duration(days: 5)),
        eventTitles: ['Event 1', 'Event 2']),
    Event(
        date: NepaliDateTime.now().add(const Duration(days: 8)),
        eventTitles: ['Seminar 1', 'Seminar 2']),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NepaliCalendar(
          language: widget.nepaliUtils, //by default Nepali
          monthYearPickerStyle:
              TextStyle(color: red, fontWeight: FontWeight.bold, fontSize: 24),
          //Color to left right button
          rightLeftButtonColor: Colors.red,
          //Styles to Week Row
          weekHeaderStyle:
              TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 26),
          initialDate: NepaliDateTime.now(),
          firstDate: NepaliDateTime(2070),
          lastDate: NepaliDateTime(2090),
          onDateChanged: (date) => _selectedDate.value = date,
          dayBuilder: (dayToBuild) {
            return Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    NepaliUtils().language == Language.english
                        ? '${dayToBuild.day}'
                        : NepaliUnicode.convert('${dayToBuild.day}'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (events.any((event) => _dayEquals(event.date, dayToBuild)))
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: red),
                    ),
                  )
              ],
            );
          },
          selectedDayDecoration: const BoxDecoration(
            color: Colors.deepOrange,
            shape: BoxShape.circle,
          ),
          todayDecoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.yellow, Colors.orange]),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<NepaliDateTime>(
            valueListenable: _selectedDate,
            builder: (context, date, _) {
              Event? event;
              try {
                event = events.firstWhere((e) => _dayEquals(e.date, date));
              } on StateError {
                event = null;
              }

              if (event == null) {
                return const Center(
                  child: Text('No Events'),
                );
              }

              return ListView.separated(
                itemCount: event.eventTitles.length,
                itemBuilder: (context, index) => ListTile(
                  leading: TodayWidget(
                    today: date,
                  ),
                  title: Text(event!.eventTitles[index]),
                  onTap: () {},
                ),
                separatorBuilder: (context, _) => const Divider(),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _dayEquals(NepaliDateTime? a, NepaliDateTime? b) =>
      a != null &&
      b != null &&
      a.toIso8601String().substring(0, 10) ==
          b.toIso8601String().substring(0, 10);
}

///
class TodayWidget extends StatelessWidget {
  ///
  final NepaliDateTime today;

  ///
  const TodayWidget({
    Key? key,
    required this.today,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: red,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  NepaliDateFormat.EEEE()
                      .format(today)
                      .substring(0, 3)
                      .toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),
            Text(
              NepaliDateFormat.d().format(today),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

///
class Event {
  ///
  final NepaliDateTime date;

  ///
  final List<String> eventTitles;

  ///
  Event({required this.date, required this.eventTitles});
}
