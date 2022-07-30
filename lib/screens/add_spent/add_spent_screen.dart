import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../models/spent.dart';
import '../../models/travel.dart';

class AddSpentScreen extends StatefulWidget {
  final Travel travel;
  const AddSpentScreen({Key? key, required this.travel}) : super(key: key);

  @override
  State<AddSpentScreen> createState() => _AddSpentScreenState();
}

class _AddSpentScreenState extends State<AddSpentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  DateTime costDate = DateTime.now();
  DateTime endDate = DateTime.now();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Viagem"),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          //child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value != null) {
                    if (value.isEmpty) {
                      return "O nome não pode ser vazio";
                    }
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  label: Text("Nome do gasto"),
                  icon: Icon(Icons.textsms),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  label: Text("Custo"),
                  icon: Icon(Icons.currency_exchange),
                  prefixText: "R\$",
                  suffixText: ",00",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              DateTimePicker(
                type: DateTimePickerType.dateTime,
                initialValue: costDate.toString(),
                firstDate: widget.travel.startDate,
                lastDate: DateTime(2100),
                dateLabelText: 'Momento do Gasto',
                onChanged: (String val) {
                  setState(() {
                    costDate = DateTime.parse(val);
                  });
                },
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveNewSpent();
                  }
                },
                child: const Text("Criar"),
              ),
            ],
          ),
        ),
        // ),
      ),
    );
  }

  saveNewSpent() {
    Spent spent = Spent(
      id: const Uuid().v1(),
      idTravel: widget.travel.id,
      name: _nameController.text,
      cost: (double.tryParse(_budgetController.text) != null)
          ? double.parse(_budgetController.text)
          : 0.0,
      createdAt: costDate,
    );

    firestore
        .collection("travels")
        .doc(spent.idTravel)
        .collection("spents")
        .doc(spent.id)
        .set(spent.toMap());

    Navigator.pop(context);
  }
}
