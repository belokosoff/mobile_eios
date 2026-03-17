import 'package:eios/data/models/time_table_lesson_discipline.dart';
import 'package:eios/presentation/screens/rating_plan/rating_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import 'bloc/timetable_bloc.dart';
import 'bloc/timetable_event.dart';
import 'bloc/timetable_state.dart';

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class TimeTableScreen extends StatelessWidget {
  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimetableBloc()..add(TimetableStarted()),
      child: const _TimetableView(),
    );
  }
}

class _TimetableView extends StatelessWidget {
  const _TimetableView();

  static const List<String> _months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  static const List<String> _periodLesson = [
    '8:00 - 9:30',
    '9:45 - 11:15',
    '11:35 - 13:05',
    '13:20 - 14:50',
    '15:00 - 16:30',
    '16:40 - 18:10',
    '18:15 - 19:45',
    '19:50-21:20',
  ];

  List<Map<String, dynamic>?> _getFormattedLessons(TimetableState state) {
    final lessonsList = List<Map<String, dynamic>?>.filled(8, null);
    if (state.timetableData == null) return lessonsList;

    for (var groupData in state.timetableData!) {
      final lessons = groupData.timeTable?.lessons ?? [];
      for (var lesson in lessons) {
        final lessonNumber = lesson.number;
        if (lessonNumber != null && lessonNumber > 0 && lessonNumber <= 8) {
          for (var discipline in lesson.disciplines ?? []) {
            lessonsList[lessonNumber - 1] = {
              'number': lessonNumber,
              'discipline': discipline,
            };
          }
        }
      }
    }
    return lessonsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TimetableBloc, TimetableState>(
            listenWhen: (prev, curr) => curr.snackBarMessage != null,
            listener: (context, state) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.snackBarMessage!)));
              context.read<TimetableBloc>().add(TimetableSnackBarDismissed());
            },
          ),
          // ── Навигация на рейтинг-план ──
          BlocListener<TimetableBloc, TimetableState>(
            listenWhen: (prev, curr) => curr.ratingPlanToNavigate != null,
            listener: (context, state) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RatingPlanScreen(
                    plan: state.ratingPlanToNavigate!,
                    disciplineTitle:
                        state.ratingPlanDisciplineTitle ?? 'Дисциплина',
                  ),
                ),
              );
              context.read<TimetableBloc>().add(TimetableNavigationHandled());
            },
          ),
          BlocListener<TimetableBloc, TimetableState>(
            listenWhen: (prev, curr) =>
                prev.isLoadingRatingPlan != curr.isLoadingRatingPlan,
            listener: (context, state) {
              if (state.isLoadingRatingPlan) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );
              } else {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
        child: BlocBuilder<TimetableBloc, TimetableState>(
          builder: (context, state) {
            final lessonItems = _getFormattedLessons(state);

            return Column(
              children: [
                // ── Календарь ──
                TableCalendar(
                  key: ValueKey(state.calendarFormat),
                  locale: 'ru_RU',
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: state.focusedDay,
                  calendarFormat: state.calendarFormat,
                  availableCalendarFormats: const {
                    CalendarFormat.twoWeeks: '2 недели',
                    CalendarFormat.week: 'Неделя',
                    CalendarFormat.month: 'Месяц',
                  },
                  headerStyle: const HeaderStyle(formatButtonShowsNext: false),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) =>
                      isSameDay(state.selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(state.selectedDay, selectedDay)) {
                      context.read<TimetableBloc>().add(
                        TimetableDateSelected(
                          selectedDay: selectedDay,
                          focusedDay: focusedDay,
                        ),
                      );
                    }
                  },
                  onFormatChanged: (format) {
                    context.read<TimetableBloc>().add(
                      TimetableFormatChanged(format),
                    );
                  },
                  onPageChanged: (focusedDay) {
                    context.read<TimetableBloc>().add(
                      TimetablePageChanged(focusedDay),
                    );
                  },
                ),

                const Divider(),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Расписание на ${state.selectedDay.day} "
                    "${_months[state.selectedDay.month - 1]} "
                    "${state.selectedDay.year}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const Divider(),

                // ── Список занятий ──
                if (state.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Expanded(
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
                              final int number = index + 1;

                              if (item == null) {
                                return _EmptyLessonSlot(
                                  number: number,
                                  periodLesson: _periodLesson,
                                );
                              }

                              final d =
                                  item['discipline']
                                      as TimeTableLessonDiscipline;

                              return _LessonCard(
                                number: number,
                                discipline: d,
                                periodLesson: _periodLesson,
                                onTap: () {
                                  context.read<TimetableBloc>().add(
                                    TimetableRatingPlanRequested(d),
                                  );
                                },
                              );
                            },
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int number;
  final TimeTableLessonDiscipline discipline;
  final List<String> periodLesson;
  final VoidCallback onTap;

  const _LessonCard({
    required this.number,
    required this.discipline,
    required this.periodLesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final d = discipline;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              "$number",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            d.title ?? '—',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.watch_later_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        (number > 0 && number <= periodLesson.length)
                            ? periodLesson[number - 1]
                            : "Время не указано",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        d.teacher?.fio ?? 'Преподаватель не указан',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Ауд. ${d.auditorium?.number ?? '—'} '
                      '(Корпус ${d.auditorium?.campusTitle ?? '—'})',
                      style: const TextStyle(fontSize: 13),
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
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.account_box, size: 40),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _EmptyLessonSlot extends StatelessWidget {
  final int number;
  final List<String> periodLesson;

  const _EmptyLessonSlot({required this.number, required this.periodLesson});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.grey.shade100,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade400,
          child: Text(
            "$number",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: const Text(
          'Нет занятия',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              const Icon(
                Icons.watch_later_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                periodLesson[number - 1],
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
