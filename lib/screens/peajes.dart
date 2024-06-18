import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/peaje.dart';
import 'registrar.dart';
import 'editar.dart'; // Asegúrate de importar la pantalla de edición correctamente

class Peajes extends StatefulWidget {
  @override
  _PeajesState createState() => _PeajesState();
}

class _PeajesState extends State<Peajes> {
  late Future<List<Peaje>> futurePeajes;

  @override
  void initState() {
    super.initState();
    futurePeajes = fetchPeajes();
  }

  Future<List<Peaje>> fetchPeajes() async {
    final response =
        await http.get(Uri.parse('http://localhost:5259/api/Peaje'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((peaje) => Peaje.fromJson(peaje)).toList();
    } else {
      throw Exception('Failed to load peajes');
    }
  }

  Future<void> deletePeaje(int id) async {
    final response =
        await http.delete(Uri.parse('http://localhost:5259/api/Peaje/$id'));

    if (response.statusCode == 200) {
      setState(() {
        futurePeajes = fetchPeajes();
      });
    } else {
      throw Exception('Failed to delete peaje');
    }
  }

  void confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar este peaje?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                deletePeaje(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editarPeaje(BuildContext context, Peaje peaje) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Editar(peaje),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {
          futurePeajes = fetchPeajes();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peajes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PeajeForm(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Peaje>>(
          future: futurePeajes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Placa')),
                    DataColumn(label: Text('Nombre Peaje')),
                    DataColumn(label: Text('Categoría')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Valor')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: snapshot.data!
                      .map((peaje) => DataRow(cells: [
                            DataCell(Text(peaje.id.toString())),
                            DataCell(Text(peaje.placa)),
                            DataCell(Text(peaje.nombrePeaje)),
                            DataCell(Text(peaje.idCategoriaTarifa)),
                            DataCell(Text(peaje.fecha.toString())),
                            DataCell(Text(peaje.valor.toString())),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editarPeaje(context, peaje),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    confirmDelete(context, peaje.id);
                                  },
                                ),
                              ],
                            )),
                          ]))
                      .toList(),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        color: Color.fromARGB(255, 45, 109, 168),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Miguelito',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            Text(
              'Teléfono: 3197437259',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
