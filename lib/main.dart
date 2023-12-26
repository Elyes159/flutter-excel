import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lecture CSV et Excel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController idController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  String result = '';
  List<List<dynamic>> csvData = [];
  String id = '';
  String brand = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lecture CSV et Excel'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: 'ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: brandController,
              decoration: InputDecoration(labelText: 'Brand'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                await _readCSVFile();
                await _searchData();
                await _saveToExcel();
              },
              child: Text('Rechercher et Enregistrer'),
            ),
            SizedBox(height: 20.0),
            Text(
              result,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _readCSVFile() async {
    var file = File('/home/kali/Downloads/Car.csv');
    var contents = await file.readAsString();
    setState(() {
      csvData = CsvToListConverter().convert(contents);
    });
    // Utilisez csvData pour la recherche
  }

  Future<void> _searchData() async {
    var idSaisi = int.tryParse(idController.text) ?? 0;
    var brandSaisi = brandController.text;

    // Recherche de la vitesse correspondante
    // Mettez ici la logique pour rechercher les données
    bool found = false;
    String speed = '';

    // Exemple de recherche dans les données CSV
    for (var row in csvData) {
      if (row[0] == idSaisi.toString() && row[2] == brandSaisi) {
        found = true;
        speed = row[3];
        break;
      }
    }

    setState(() {
      if (found) {
        result =
            'Vitesse trouvée pour ID: $idSaisi et Marque: $brandSaisi est $speed';
      } else {
        result = 'Erreur : Les données saisies ne sont pas trouvées.';
      }
    });
  }

  Future<void> _saveToExcel() async {
    id = idController.text;
    brand = brandController.text;

    var excel = Excel.createExcel();
    var sheet = excel['NouvelleFeuille'];

    var idCellValue = id != null ? Cell.fromString(id) : null;
    var brandCellValue = brand != null ? CellValue(serialize: brand) : null;

    var row = sheet.maxRows + 1;
    sheet.appendRow([idCellValue, brandCellValue]);

    var directory = await getApplicationDocumentsDirectory();
    var filePath = path.join(directory.path, 'sopal_fichier.xlsx');
    var file = File(filePath);

    var excelData = excel.encode();
    if (excelData != null) {
      await file.writeAsBytes(excelData.cast<int>());
      print('Données du formulaire enregistrées dans le fichier Excel.');
    } else {
      print(
          'Erreur lors de l\'enregistrement des données dans le fichier Excel.');
    }
  }
}
