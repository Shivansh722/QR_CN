import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegesteredPpl extends StatelessWidget {
  const RegesteredPpl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered People'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('responses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              final name = doc['name'] ?? 'No name';
              final email = doc['email'] ?? 'No email';
              final phone = doc['phone'] ?? 'No phone';

              return ListTile(
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: $email'),
                    Text('Phone: $phone'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
