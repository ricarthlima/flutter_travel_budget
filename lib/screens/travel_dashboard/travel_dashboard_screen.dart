import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_travel_budget/screens/add_spent/add_spent_screen.dart';
import 'package:flutter_travel_budget/screens/add_travel/add_travel_screen.dart';

import '../../models/spent.dart';
import '../../models/travel.dart';

class TravelDashboardScreen extends StatefulWidget {
  final Travel travel;
  const TravelDashboardScreen({Key? key, required this.travel})
      : super(key: key);

  @override
  State<TravelDashboardScreen> createState() => _TravelDashboardScreenState();
}

class _TravelDashboardScreenState extends State<TravelDashboardScreen> {
  List<Spent> listSpents = [];
  double totalSpent = 0;
  double totalSpentToday = 0;
  double amountLeft = 0;
  double dailySpentSuggestion = 0;
  int daysLeft = 0;
  double initialAvg = 0;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    setupListeners();
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.travel.name} - $daysLeft dias restantes"),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSpentScreen(
                travel: widget.travel,
              ),
            ),
          );
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          const Text(
            "Informações Principais",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
          ),
          const Text("Sobre os gastos diários"),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(
              "R\$ $totalSpentToday",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            subtitle: const Text("Total gasto hoje."),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(
              "R\$ $dailySpentSuggestion",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            subtitle: const Text("Gasto máximo diário sugerido."),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(
              "R\$ $initialAvg",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            tileColor: const Color.fromARGB(30, 255, 255, 255),
            subtitle: const Text("Valor diário previsto."),
            trailing: const Text("VALOR FIXO"),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
          ),
          const Text("Sobre os totais"),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(
              "R\$ $totalSpent",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            subtitle: const Text("Total gasto."),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(
              "R\$ $amountLeft",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            subtitle: const Text("Orçamento restante."),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(
              "R\$ ${widget.travel.budget}",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            tileColor: const Color.fromARGB(30, 255, 255, 255),
            subtitle: const Text("Total do Orçamento."),
            trailing: const Text("VALOR FIXO"),
          ),
          const Padding(padding: EdgeInsets.all(32), child: Divider()),
          const Text(
            "Progresso dos Gastos",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(padding: EdgeInsets.all(32), child: Divider()),
          const Text(
            "Lista de gastos",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            children: List.generate(
              listSpents.length,
              (index) {
                Spent spent = listSpents[index];
                return ListTile(
                  onTap: () {},
                  title: Text(spent.name),
                  subtitle: Text(
                    "R\$ ${spent.cost.toString()},00 - ${spent.createdAt.toString()}",
                  ),
                  leading: const Icon(Icons.place),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      delete(spent);
                    },
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }

  setupListeners() {
    firestore
        .collection("travels")
        .doc(widget.travel.id)
        .collection("spents")
        .snapshots()
        .listen(
      (snapshot) {
        listSpents = [];

        for (DocumentSnapshot doc in snapshot.docs) {
          setState(() {
            listSpents.add(
              Spent.fromMap(doc.data()),
            );
          });
        }

        refresh();
      },
    );
  }

  refresh() {
    setState(
      () {
        initialAvg = ((widget.travel.budget /
                        widget.travel.startDate
                            .difference(widget.travel.endDate)
                            .inDays
                            .abs()) *
                    100)
                .toInt() /
            100;
        totalSpent = 0;
        totalSpentToday = 0;
        for (var spent in listSpents) {
          totalSpent += spent.cost;

          if (spent.createdAt.day == DateTime.now().day) {
            totalSpentToday += spent.cost;
          }
        }
        amountLeft = widget.travel.budget - totalSpent;
        daysLeft =
            widget.travel.endDate.difference(DateTime.now()).inDays.abs();
        dailySpentSuggestion = amountLeft / daysLeft;
        dailySpentSuggestion = (dailySpentSuggestion * 100).toInt() / 100;
      },
    );
  }

  delete(Spent spent) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Atenção!"),
          content: Text("Deseja remover esse gasto: ${spent.name}?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar")),
            TextButton(
                onPressed: () {
                  setState(() {
                    firestore
                        .collection("travels")
                        .doc(spent.idTravel)
                        .collection("spents")
                        .doc(spent.id)
                        .delete();
                    Navigator.pop(context);
                  });
                },
                child: const Text("Remover")),
          ],
        );
      },
    );
  }
}
