import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<dynamic> entries = [];
  bool loading = true;
  bool badWeek = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ----------------------------
  // Cargar datos reales del back
  // ----------------------------
  Future<void> loadData() async {
    final data = await ApiService.getEntries();
    final last7 = data.take(7).toList().reversed.toList();

    int streak = 0;
    for (var e in last7) {
      final score = emotionToScore(e["text_emotion"]);
      if (score <= 2) {
        streak++;
        if (streak >= 3) badWeek = true;
      } else {
        streak = 0;
      }
    }

    setState(() {
      entries = last7;
      loading = false;
    });

    if (badWeek) showHelpDialog();
  }

  // ----------------------------
  // Conversión emoción → score
  // ----------------------------
  int emotionToScore(String e) {
    switch (e) {
      case "Happy":
        return 5;
      case "Surprise":
        return 4;
      case "Neutral":
        return 3;
      case "Sad":
        return 2;
      case "Angry":
        return 1;
      default:
        return 3;
    }
  }

  // ----------------------------
  // Alerta bonita
  // ----------------------------
  void showHelpDialog() {
    Future.delayed(const Duration(milliseconds: 400), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("💙 Estamos contigo"),
          content: const Text(
            "Se detectaron varios días difíciles.\n\n"
            "Contactos de ayuda:\n"
            "• ECU 911\n"
            "• Ministerio de Salud: 102\n"
            "• Línea internacional: 988\n\n"
            "Pedir ayuda es un acto de valentía.",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendido"),
            ),
          ],
        ),
      );
    });
  }

  // ----------------------------
  // UI
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final scores = entries
        .map((e) => emotionToScore(e["text_emotion"]).toDouble())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Análisis semanal"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryCard(),
            const SizedBox(height: 24),
            _lineChart(scores),
            const SizedBox(height: 32),
            _pieChartWithLegend(),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // Tarjeta resumen
  // ----------------------------
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: badWeek ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Text(
          badWeek
              ? "Semana difícil 💙\nNo estás solo"
              : "Semana estable 🌸\nBuen trabajo",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: badWeek ? Colors.red.shade700 : Colors.green.shade700,
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // Gráfico de línea (colores por emoción)
  // ----------------------------
  Widget _lineChart(List<double> scores) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          minY: 0.5,
          maxY: 5.5,
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              barWidth: 4,
              spots: scores
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: _scoreColor(spot.y),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              color: Colors.pinkAccent.shade100,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.pinkAccent.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double v) {
    if (v >= 4.5) return Colors.yellow.shade400;
    if (v >= 3.5) return Colors.purple.shade300;
    if (v >= 2.5) return Colors.blueGrey.shade300;
    if (v >= 1.5) return Colors.blue.shade300;
    return Colors.red.shade300;
  }

  // ----------------------------
  // Gráfico de pastel + leyenda
  // ----------------------------
  Widget _pieChartWithLegend() {
    final counts = <String, int>{};
    for (var e in entries) {
      counts[e["text_emotion"]] =
          (counts[e["text_emotion"]] ?? 0) + 1;
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sectionsSpace: 4,
              sections: counts.entries.map((e) {
                return PieChartSectionData(
                  value: e.value.toDouble(),
                  title: "${e.value}",
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: _emotionColor(e.key),
                  radius: 70,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: counts.keys.map((e) {
            return _legendItem(e);
          }).toList(),
        ),
      ],
    );
  }

  Widget _legendItem(String emotion) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: _emotionColor(emotion),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(emotion),
      ],
    );
  }

  Color _emotionColor(String e) {
    switch (e) {
      case "Happy":
        return Colors.yellow.shade400;
      case "Surprise":
        return Colors.purple.shade300;
      case "Neutral":
        return Colors.blueGrey.shade300;
      case "Sad":
        return Colors.blue.shade300;
      case "Angry":
        return Colors.red.shade300;
      default:
        return Colors.grey;
    }
  }
}
