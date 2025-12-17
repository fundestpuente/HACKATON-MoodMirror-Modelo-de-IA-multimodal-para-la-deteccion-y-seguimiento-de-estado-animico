import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List entries = [];

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future loadEntries() async {
    final data = await ApiService.getEntries();
    setState(() => entries = data);
  }

  Future deleteEntry(int id) async {
    await ApiService.deleteEntry(id);
    await loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Progreso Semanal")),
      body: entries.isEmpty
          ? Center(child: Text("No hay entradas aún"))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final e = entries[i];

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FILA SUPERIOR: fecha + botón borrar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e["date"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text("¿Eliminar entrada?"),
                                    content: Text("Esta acción no se puede deshacer."),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Cancelar"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await deleteEntry(e["id"]);
                                        },
                                        child: Text("Eliminar", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),

                        SizedBox(height: 6),

                        Text(
                          "Nota: ${e["text_note"]}",
                          style: TextStyle(fontSize: 15),
                        ),

                        SizedBox(height: 10),

                        Text(
                          e["advice"],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
