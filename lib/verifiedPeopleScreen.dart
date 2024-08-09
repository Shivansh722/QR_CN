import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifiedPeopleScreen extends StatefulWidget {
  const VerifiedPeopleScreen({super.key});

  @override
  State<VerifiedPeopleScreen> createState() => _VerifiedPeopleScreenState();
}

class _VerifiedPeopleScreenState extends State<VerifiedPeopleScreen> {
  int boysCount = 0;
  int girlsCount = 0;
  bool hasFetchedGenderCount = false;

  Future<void> _getGenderCount(List<String> names) async {
    final url = Uri.parse('https://gender-counter.onrender.com/count');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'names': names}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final responseText = data['response'] as String;

      final boysMatch = RegExp(r'Boys: (\d+)').firstMatch(responseText);
      final girlsMatch = RegExp(r'Girls: (\d+)').firstMatch(responseText);

      setState(() {
        boysCount = int.tryParse(boysMatch?.group(1) ?? '0') ?? 0;
        girlsCount = int.tryParse(girlsMatch?.group(1) ?? '0') ?? 0;
        hasFetchedGenderCount = true;
      });
    } else {
      throw Exception('Failed to load gender counts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Verified People', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('responses')
              .where('is_scanned', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data', style: TextStyle(color: Colors.white)));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.docs;
            final List<String> names = data.map((doc) => doc['name'] as String).toList();

            if (!hasFetchedGenderCount) {
              _getGenderCount(names);
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Verified People: ${data.length}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Boys: $boysCount',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        'Girls: $girlsCount',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final doc = data[index];
                      final name = doc['name'] ?? 'No name';
                      final email = doc['email'] ?? 'No email';
                      final phone = doc['phone'] ?? 'No phone';

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.person, color: Colors.white),
                            title: Text(name, style: const TextStyle(color: Colors.white)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: $email', style: const TextStyle(color: Colors.white70)),
                                Text('Phone: $phone', style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
