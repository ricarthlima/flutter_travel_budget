import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_travel_budget/screens/add_travel/add_travel_screen.dart';
import 'package:flutter_travel_budget/screens/travel_dashboard/travel_dashboard_screen.dart';

import '../../models/travel.dart';

class TravelsListScreen extends StatefulWidget {
  const TravelsListScreen({Key? key}) : super(key: key);

  @override
  State<TravelsListScreen> createState() => _TravelsListScreenState();
}

class _TravelsListScreenState extends State<TravelsListScreen> {
  List<Travel> listTravel = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    setupListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Viagens"),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: listTravel.length,
          itemBuilder: (BuildContext context, int index) {
            Travel travel = listTravel[index];
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TravelDashboardScreen(travel: travel)),
                );
              },
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTravelScreen(
                      travel: travel,
                    ),
                  ),
                );
              },
              title: Text(
                "${travel.name} - R\$ ${travel.budget},00",
                style: const TextStyle(fontSize: 24),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Do dia ${travel.startDate.day} de ${travel.startDate.month} até o dia ${travel.endDate.day} de ${travel.endDate.month}")
                ],
              ),
              leading: const Icon(Icons.place, size: 32),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  delete(travel);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTravelScreen(),
            ),
          );
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
      ),
    );
  }

  setupListeners() {
    firestore.collection("travels").snapshots().listen((snapshot) {
      listTravel = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        setState(() {
          listTravel.add(
            Travel.fromMap(doc.data()),
          );
        });
      }
    });
  }

  refreshManually() {
    listTravel = [];
    firestore.collection("travels").get().then((value) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = value.docs;
      for (var doc in docs) {
        setState(() {
          listTravel.add(
            Travel.fromMap(doc.data()),
          );
        });
      }
    });
  }

  delete(Travel travel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Atenção!"),
          content: Text("Deseja remover a viagem para ${travel.name}?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar")),
            TextButton(
                onPressed: () {
                  setState(() {
                    firestore.collection("travels").doc(travel.id).delete();
                    refreshManually();
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
