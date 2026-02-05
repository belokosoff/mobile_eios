import 'package:eios/data/models/student_rating_plan.dart';
import 'package:flutter/material.dart';
import 'package:eios/data/models/student_semestr.dart'; 
import 'package:eios/data/repositories/brs_repository.dart';

class SemestrScreen extends StatefulWidget {
  const SemestrScreen({super.key});

  @override
  _SemestrScreenState createState() => _SemestrScreenState();
}

class _SemestrScreenState extends State<SemestrScreen> {
  final BrsRepository _repository = BrsRepository();
  bool _isLoading = false;
  List<StudentSemestr>? _semesters;
  StudentRatingPlan? _ratingPlan;
  @override
  void initState() {
    super.initState();
    _loadStudentSemestr();
  }

  Future<void> _loadStudentSemestr() async {
    setState(() => _isLoading = true);

    try {
      final data = await _repository.getStudentSemestr();
      if (mounted) {
        setState(() {
          _semesters = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
  }

/* Future<void> _loadStudentSemestr() async {
    setState(() => _isLoading = true);

    try {
      final data = await _repository.getStudentSemestr();
      if (mounted) {
        setState(() {
          _semesters = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
  } */


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Успеваемость"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _semesters == null || _semesters!.isEmpty
              ? const Center(child: Text("Данные отсутствуют"))
              : RefreshIndicator(
                  onRefresh: _loadStudentSemestr,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _semesters!.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _semesters![index];
                      return _buildSemesterCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildSemesterCard(StudentSemestr item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          "${item.year}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Семестр: ${item.period}"),
        trailing: _buildNotificationBadge(item.unreadedDisCount),
        onTap: () {
          // Здесь можно добавить переход к деталям конкретного семестра
        },
      ),
    );
  }

  Widget? _buildNotificationBadge(int? count) {
    if (count == null || count == 0) return const Icon(Icons.chevron_right);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}