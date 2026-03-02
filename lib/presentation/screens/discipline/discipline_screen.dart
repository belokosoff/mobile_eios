import 'package:eios/data/models/discipline.dart';
import 'package:eios/data/models/record_book.dart';
import 'package:eios/presentation/screens/messages/messages_screen.dart';
import 'package:eios/presentation/screens/rating_plan/rating_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/discipline_list_bloc.dart';
import 'bloc/discipline_list_event.dart';
import 'bloc/discipline_list_state.dart';

class DisciplineListScreen extends StatelessWidget {
  const DisciplineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DisciplineListBloc()..add(DisciplineListStarted()),
      child: const _DisciplineListView(),
    );
  }
}

class _DisciplineListView extends StatelessWidget {
  const _DisciplineListView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DisciplineListBloc, DisciplineListState>(
          listenWhen: (prev, curr) => curr.snackBarMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.snackBarMessage!)));
            context.read<DisciplineListBloc>().add(
              DisciplineListSnackBarDismissed(),
            );
          },
        ),
        BlocListener<DisciplineListBloc, DisciplineListState>(
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
        BlocListener<DisciplineListBloc, DisciplineListState>(
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
            context.read<DisciplineListBloc>().add(
              DisciplineListNavigationHandled(),
            );
          },
        ),
      ],
      child: BlocBuilder<DisciplineListBloc, DisciplineListState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Успеваемость"),
              bottom: state.isSemestersLoading
                  ? null
                  : PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: _Selectors(),
                    ),
            ),
            body: state.isSemestersLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      if (state.isLoadingDisciplines)
                        const LinearProgressIndicator(),
                      Expanded(
                        child:
                            state.recordBooks.isEmpty &&
                                !state.isLoadingDisciplines
                            ? const Center(child: Text("Дисциплины не найдены"))
                            : RefreshIndicator(
                                onRefresh: () async {
                                  context.read<DisciplineListBloc>().add(
                                    DisciplineListRefreshed(),
                                  );
                                },
                                child: _RecordBooksList(
                                  recordBooks: state.recordBooks,
                                ),
                              ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _Selectors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisciplineListBloc, DisciplineListState>(
      buildWhen: (prev, curr) =>
          prev.selectedYear != curr.selectedYear ||
          prev.selectedPeriod != curr.selectedPeriod ||
          prev.availableSemesters != curr.availableSemesters,
      builder: (context, state) {
        final years = state.availableYears;
        final periods = state.availablePeriods;

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: state.selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Год',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: years
                      .map(
                        (y) => DropdownMenuItem(value: y, child: Text(y ?? "")),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      context.read<DisciplineListBloc>().add(
                        DisciplineListYearChanged(val),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: state.selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Семестр',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: periods
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      context.read<DisciplineListBloc>().add(
                        DisciplineListPeriodChanged(val),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecordBooksList extends StatelessWidget {
  final List<RecordBook> recordBooks;

  const _RecordBooksList({required this.recordBooks});

  @override
  Widget build(BuildContext context) {
    if (recordBooks.length == 1) {
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: recordBooks.first.disciplines?.length ?? 0,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _DisciplineCard(
            discipline: recordBooks.first.disciplines![index],
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: recordBooks.length,
      itemBuilder: (context, index) {
        return _RecordBookSection(recordBook: recordBooks[index]);
      },
    );
  }
}

class _RecordBookSection extends StatelessWidget {
  final RecordBook recordBook;

  const _RecordBookSection({required this.recordBook});

  @override
  Widget build(BuildContext context) {
    final disciplines = recordBook.disciplines ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(Icons.book, color: Theme.of(context).primaryColor),
          ),
          title: Text(
            recordBook.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            '${disciplines.length} дисциплин(ы)',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          children: disciplines
              .map(
                (d) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: _DisciplineCard(discipline: d),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DisciplineCard extends StatelessWidget {
  final Discipline discipline;

  const _DisciplineCard({required this.discipline});

  @override
  Widget build(BuildContext context) {
    final hasMessages = (discipline.unreadedMessageCount ?? 0) > 0;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          discipline.title ?? "Без названия",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (discipline.specialty != null)
              Text(
                discipline.specialty!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (hasMessages)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.mail, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      "Сообщений: ${discipline.unreadedMessageCount}",
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Badge(
                isLabelVisible: hasMessages,
                label: Text(
                  '${discipline.unreadedMessageCount ?? 0}',
                  style: const TextStyle(fontSize: 10),
                ),
                child: Icon(
                  hasMessages ? Icons.forum : Icons.forum_outlined,
                  color: hasMessages ? Colors.blue : Colors.grey,
                ),
              ),
              onPressed: () => _openMessages(context),
              tooltip: 'Форум',
            ),
            _buildBadge(discipline.unreadedCount),
          ],
        ),
        onTap: () => _showActions(context),
      ),
    );
  }

  void _openMessages(BuildContext context) {
    final id = discipline.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: ID дисциплины не найден')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessagesScreen(
          disciplineId: id,
          disciplineName: discipline.title ?? 'Дисциплина',
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    final hasMessages = (discipline.unreadedMessageCount ?? 0) > 0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  discipline.title ?? "Дисциплина",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.assignment,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Рейтинг-план'),
                subtitle: const Text('Просмотр оценок и заданий'),
                trailing: _buildBadge(discipline.unreadedCount),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  context.read<DisciplineListBloc>().add(
                    DisciplineListRatingPlanRequested(discipline),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Badge(
                    isLabelVisible: hasMessages,
                    child: const Icon(Icons.forum, color: Colors.blue),
                  ),
                ),
                title: const Text('Форум'),
                subtitle: Text(
                  hasMessages
                      ? 'Новых сообщений: ${discipline.unreadedMessageCount}'
                      : 'Обсуждение дисциплины',
                ),
                trailing: hasMessages
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${discipline.unreadedMessageCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _openMessages(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int? count) {
    if (count == null || count == 0) {
      return const Icon(Icons.chevron_right);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "$count",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
