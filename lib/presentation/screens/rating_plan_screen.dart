import 'package:eios/data/models/student_rating_plan.dart';
import 'package:flutter/material.dart';
import 'package:eios/data/models/rating_plan_section.dart';
import 'package:eios/data/models/control_dot.dart';

class RatingPlanScreen extends StatelessWidget {
  final StudentRatingPlan plan;
  final String disciplineTitle;

  const RatingPlanScreen({
    super.key,
    required this.plan,
    required this.disciplineTitle,
  });

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    DateTime? parsedDate = DateTime.tryParse(date.toString());
    if (parsedDate == null) return '—';
    return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // Проверяем наличие разделов
    final hasSections = plan.sections != null && plan.sections!.isNotEmpty;
    final hasZeroSession = plan.markZeroSession != null;
    final hasContent = hasSections || hasZeroSession;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(disciplineTitle, style: const TextStyle(fontSize: 18)),
            const Text(
              'Рейтинг-план',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: !hasContent
          ? _buildEmptyState(context)
          : ListView(
              children: [
                if (hasZeroSession)
                  _buildZeroSessionHeader(plan.markZeroSession!.ball),

                if (hasSections)
                  ...(plan.sections?..sort((a, b) {
                        bool isAFinal = (a.sectionType ?? 0) > 10;
                        bool isBFinal = (b.sectionType ?? 0) > 10;

                        if (isAFinal != isBFinal) {
                          return isAFinal ? 1 : -1;
                        }

                        return (a.order ?? 0).compareTo(b.order ?? 0);
                      }))!
                      .map((section) => _buildSection(context, section)),

                const SizedBox(height: 16),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Рейтинг-план пуст',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Для этой дисциплины еще не загружен рейтинг-план',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Вернуться назад'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZeroSessionHeader(double? ball) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                "Допуск (Нулевая сессия)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${ball ?? 0} б.",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, RatingPlanSection section) {
    // Проверяем наличие контрольных точек в разделе
    final hasControlDots =
        section.controlDots != null && section.controlDots!.isNotEmpty;

    // Считаем общий балл и максимальный балл для раздела
    double totalScore = 0;
    double maxScore = 0;

    if (hasControlDots) {
      for (var dot in section.controlDots!) {
        totalScore += dot.mark?.ball ?? 0;
        maxScore += dot.maxBall ?? 0;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                section.title ?? "Раздел без названия",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (hasControlDots)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreColor(totalScore, maxScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${totalScore.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(totalScore, maxScore),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(_getSectionLabel(section.sectionType ?? 0)),
        initiallyExpanded: true,
        children: hasControlDots
            ? section.controlDots!.map((dot) => _buildControlDot(dot)).toList()
            : [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Нет контрольных точек',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildControlDot(ControlDot dot) {
    final hasScore = dot.mark != null && dot.mark!.ball! > 0;
    final percentage = dot.maxBall != null && dot.maxBall! > 0
        ? ((dot.mark?.ball ?? 0) / dot.maxBall! * 100)
        : 0.0;

    return ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 3,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(dot.mark?.ball ?? 0, dot.maxBall ?? 0),
              ),
            ),
          ),
          Icon(
            hasScore ? Icons.check : Icons.access_time,
            size: 18,
            color: hasScore ? Colors.green : Colors.grey,
          ),
        ],
      ),
      title: Text(
        dot.title ?? "Контрольная точка",
        style: TextStyle(
          decoration: hasScore ? null : TextDecoration.none,
          color: hasScore ? null : Colors.grey[700],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Срок: ${_formatDate(dot.date)}",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "${dot.mark?.ball ?? 0}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getScoreColor(dot.mark?.ball ?? 0, dot.maxBall ?? 0),
            ),
          ),
          Text(
            "из ${dot.maxBall ?? 0}",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          if (percentage > 0)
            Text(
              "${percentage.toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 10,
                color: _getScoreColor(dot.mark?.ball ?? 0, dot.maxBall ?? 0),
              ),
            ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score, double maxScore) {
    if (maxScore == 0) return Colors.grey;
    final percentage = score / maxScore;

    if (percentage >= 0.85) return Colors.green;
    if (percentage >= 0.70) return Colors.orange;
    if (percentage >= 0.50) return Colors.deepOrange;
    return Colors.red;
  }

  String _getSectionLabel(int type) {
    switch (type) {
      case 10:
        return "Текущий контроль";
      case 20:
        return "Зачет";
      case 30:
        return "Экзамен";
      case 40:
        return "Курсовая работа";
      default:
        return "Раздел";
    }
  }
}
