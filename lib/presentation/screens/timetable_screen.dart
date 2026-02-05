import 'dart:collection';
import 'dart:developer';

import 'package:eios/data/models/student_time_table.dart';
import 'package:eios/data/models/time_table_lesson_discipline.dart';
import 'package:eios/data/repositories/timetable_repository.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource =
    {
      for (var item in List.generate(50, (index) => index))
        DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
          item % 4 + 1,
          (index) => Event('Event $item | ${index + 1}'),
        ),
    }..addAll({
      kToday: [const Event("Today's Event 1"), const Event("Today's Event 2")],
    });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<StudentTimeTable>? _timetableData;
  bool _isLoading = false;

  final TimetableRepository _repository = TimetableRepository();

  Future<void> _loadTimetable(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final data = await _repository.getStudentTimeTable(date: formattedDate);
      if (mounted) {
        setState(() {
          _timetableData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _timetableData = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTimetable(_focusedDay);
  }

  List<Map<String, dynamic>> _getFormattedLessons() {
    final lessonsList = <Map<String, dynamic>>[];
    if (_timetableData == null) return lessonsList;

    for (var groupData in _timetableData!) {
      final lessons = groupData.timeTable?.lessons ?? [];
      for (var lesson in lessons) {
        final lessonNumber = lesson.number;
        for (var discipline in lesson.disciplines ?? []) {
          lessonsList.add({'number': lessonNumber, 'discipline': discipline});
        }
      }
    }
    lessonsList.sort(
      (a, b) => (a['number'] as int).compareTo(b['number'] as int),
    );
    return lessonsList;
  }

  List<TimeTableLessonDiscipline> _getDisciplines() {
    final disciplines = <TimeTableLessonDiscipline>[];
    if (_timetableData != null) {
      for (final tt in _timetableData!) {
        final timeTable = tt.timeTable;
        if (timeTable?.lessons != null) {
          for (final lesson in timeTable!.lessons!) {
            if (lesson.disciplines != null) {
              disciplines.addAll(lesson.disciplines!);
            }
          }
        }
      }
    }
    return disciplines;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _selectedDay ?? _focusedDay;
    final lessonItems = _getFormattedLessons();
    final disciplines = _getDisciplines();

    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadTimetable(selectedDay);
              }

              log('Выбрана дата: ${selectedDay.toString()}');
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Расписание на ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: lessonItems.isEmpty
                      ? const Center(child: Text("Нет занятий"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: lessonItems.length,
                          itemBuilder: (context, index) {
                            final item = lessonItems[index];
                            final int number = item['number'];
                            final d =
                                item['discipline'] as TimeTableLessonDiscipline;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  child: Text(
                                    "$number", // Номер пары
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  d.title ?? '—',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              d.teacher?.fio ??
                                                  'Преподаватель не указан',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Ауд. ${d.auditorium?.number ?? '—'} (Корпус ${d.auditorium?.campusTitle ?? '—'})',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: d.teacher?.photo?.urlSmall != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          d.teacher!.photo!.urlSmall!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.account_box,
                                                    size: 40,
                                                  ),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
