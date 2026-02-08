// lib/presentation/screens/discipline_list_screen.dart
import 'package:eios/data/models/discipline.dart';
import 'package:eios/data/models/record_book.dart';
import 'package:eios/data/models/student_semestr.dart';
import 'package:eios/data/repositories/brs_repository.dart';
import 'package:eios/data/repositories/timetable_repository.dart';
import 'package:eios/presentation/screens/messages_screeen.dart';
import 'package:eios/presentation/screens/rating_plan_screen.dart';
import 'package:flutter/material.dart';

class DisciplineListScreen extends StatefulWidget {
  const DisciplineListScreen({super.key});

  @override
  State<DisciplineListScreen> createState() => _DisciplineListScreenState();
}

class _DisciplineListScreenState extends State<DisciplineListScreen> {
  final BrsRepository _brsRepository = BrsRepository();
  final TimetableRepository _timetableRepository = TimetableRepository();

  bool _isLoadingSemesters = true;
  bool _isLoadingDisciplines = false;

  List<StudentSemestr> _availableSemesters = [];
  List<RecordBook> _recordBooks = [];

  String? _selectedYear = "2025 - 2026";
  int? _selectedPeriod = 2;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final data = await _brsRepository.getStudentSemestr();
      if (mounted && data.isNotEmpty) {
        setState(() {
          _availableSemesters = data;
          _selectedYear = data.first.year;
          _selectedPeriod = data.first.period;
          _isLoadingSemesters = false;
        });
        _fetchDisciplines();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSemesters = false);
        _showError('Ошибка загрузки семестров: $e');
      }
    }
  }

  Future<void> _fetchDisciplines() async {
    if (_selectedYear == null || _selectedPeriod == null) return;

    setState(() => _isLoadingDisciplines = true);
    try {
      final result = await _brsRepository.getDisciplinesBySemester(
        year: _selectedYear!,
        period: _selectedPeriod!,
      );

      if (mounted) {
        setState(() {
          _recordBooks = result.recordBooks?.map((rb) {
            return RecordBook(
              cod: rb.cod,
              number: rb.number,
              faculty: rb.faculty,
              disciplines: rb.disciplines
                  ?.where((d) => d.relevance != false)
                  .toList(),
            );
          }).where((rb) => rb.disciplines?.isNotEmpty ?? false).toList() ?? [];
          
          _isLoadingDisciplines = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDisciplines = false);
        _showError('Ошибка загрузки дисциплин: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Успеваемость"),
        bottom: _isLoadingSemesters
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: _buildSelectors(),
              ),
      ),
      body: _isLoadingSemesters
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_isLoadingDisciplines) const LinearProgressIndicator(),
                Expanded(
                  child: _recordBooks.isEmpty && !_isLoadingDisciplines
                      ? const Center(child: Text("Дисциплины не найдены"))
                      : RefreshIndicator(
                          onRefresh: _fetchDisciplines,
                          child: _buildRecordBooksList(),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRecordBooksList() {
    if (_recordBooks.length == 1) {
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _recordBooks.first.disciplines?.length ?? 0,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _buildDisciplineCard(_recordBooks.first.disciplines![index]);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _recordBooks.length,
      itemBuilder: (context, index) {
        return _buildRecordBookSection(_recordBooks[index]);
      },
    );
  }

  Widget _buildRecordBookSection(RecordBook recordBook) {
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
            child: Icon(
              Icons.book,
              color: Theme.of(context).primaryColor,
            ),
          ),
          title: Text(
            recordBook.displayName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${disciplines.length} дисциплин(ы)',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          children: disciplines.map((discipline) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _buildDisciplineCard(discipline),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSelectors() {
    final years = _availableSemesters.map((e) => e.year).toSet().toList();
    final periods = _availableSemesters
        .where((e) => e.year == _selectedYear)
        .map((e) => e.period)
        .toList();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Год',
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              items: years
                  .map((y) => DropdownMenuItem(value: y, child: Text(y ?? "")))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedYear = val;
                  _selectedPeriod = _availableSemesters
                      .firstWhere((e) => e.year == val)
                      .period;
                });
                _fetchDisciplines();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Семестр',
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              items: periods
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p.toString())))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedPeriod = val);
                _fetchDisciplines();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplineCard(Discipline discipline) {
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
            // Кнопка сообщений
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
              onPressed: () => _openMessages(discipline),
              tooltip: 'Форум',
            ),
            _buildBadge(discipline.unreadedCount),
          ],
        ),
        onTap: () => _showDisciplineActions(discipline),
      ),
    );
  }

  /// Показать BottomSheet с выбором действия
  void _showDisciplineActions(Discipline discipline) {
    final hasMessages = (discipline.unreadedMessageCount ?? 0) > 0;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
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
              
              // Рейтинг-план
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.assignment,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Рейтинг-план'),
                subtitle: const Text('Просмотр оценок и заданий'),
                trailing: _buildBadge(discipline.unreadedCount),
                onTap: () {
                  Navigator.pop(context);
                  _openDisciplineDetails(discipline);
                },
              ),
              
              // Форум / Сообщения
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Badge(
                    isLabelVisible: hasMessages,
                    child: const Icon(
                      Icons.forum,
                      color: Colors.blue,
                    ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  Navigator.pop(context);
                  _openMessages(discipline);
                },
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Открыть экран сообщений
  void _openMessages(Discipline discipline) {
    final disciplineId = discipline.id;
    if (disciplineId == null) {
      _showError('Ошибка: ID дисциплины не найден');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesScreen(
          disciplineId: disciplineId,
          disciplineName: discipline.title ?? 'Дисциплина',
        ),
      ),
    );
  }

  Future<void> _openDisciplineDetails(Discipline discipline) async {
    final disciplineId = discipline.id;
    if (disciplineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка: ID дисциплины не найден")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ratingPlan = await _timetableRepository
          .getRatingPlan(disciplineId)
          .timeout(const Duration(seconds: 15));

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RatingPlanScreen(
              plan: ratingPlan,
              disciplineTitle: discipline.title ?? "Дисциплина",
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        Navigator.pop(context);

        String errorMessage = "Не удалось загрузить план";
        if (e.toString().contains('TimeoutException')) {
          errorMessage = "Превышено время ожидания. Проверьте интернет.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$errorMessage: $e")),
        );
      }
    }
  }

  Widget _buildBadge(int? count) {
    if (count == null || count == 0) return const Icon(Icons.chevron_right);
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