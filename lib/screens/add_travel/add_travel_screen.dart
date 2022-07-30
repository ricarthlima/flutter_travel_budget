import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../models/travel.dart';

class AddTravelScreen extends StatefulWidget {
  final Travel? travel;
  const AddTravelScreen({Key? key, this.travel}) : super(key: key);

  @override
  State<AddTravelScreen> createState() => _AddTravelScreenState();
}

class _AddTravelScreenState extends State<AddTravelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  bool builded = false;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (!builded) {
      if (widget.travel != null) {
        _nameController.text = widget.travel!.name;
        _budgetController.text = widget.travel!.budget.toString();
        startDate = widget.travel!.startDate;
        endDate = widget.travel!.endDate;
      }
      builded = true;
    }
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
                  label: Text("Nome da viagem:"),
                  icon: Icon(Icons.textsms),
                ),
              ),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  label: Text("Orçamento previsto:"),
                  icon: Icon(Icons.currency_exchange),
                  prefixText: "R\$",
                  suffixText: ",00",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              DateTimePicker(
                initialValue: startDate.toString(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                dateLabelText: 'Dia de começo:',
                onChanged: (val) {
                  setState(() {
                    startDate = DateTime.parse(val);
                  });
                },
              ),
              DateTimePicker(
                initialValue: endDate.toString(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                dateLabelText: 'Dia de fim:',
                onChanged: (val) {
                  setState(() {
                    endDate = DateTime.parse(val);
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveNewTravel();
                  }
                },
                child: Text((widget.travel != null) ? "Salvar" : "Criar"),
              ),
            ],
          ),
        ),
        // ),
      ),
    );
  }

  saveNewTravel() {
    Travel travel = Travel(
      id: (widget.travel != null) ? widget.travel!.id : const Uuid().v1(),
      name: _nameController.text,
      budget: (double.tryParse(_budgetController.text) != null)
          ? double.parse(_budgetController.text)
          : 0.0,
      startDate: startDate,
      endDate: endDate,
    );

    firestore.collection("travels").doc(travel.id).set(travel.toMap());

    Navigator.pop(context);
  }
}
