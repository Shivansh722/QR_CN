import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisteredPpl extends StatefulWidget {
  const RegisteredPpl({super.key});

  @override
  State<RegisteredPpl> createState() => _RegisteredPplState();
}

class _RegisteredPplState extends State<RegisteredPpl> {
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

  Future<void> _launchWhatsApp(String phoneNumber) async {
    String formattedPhoneNumber = phoneNumber.startsWith('0')
        ? phoneNumber.substring(1)
        : phoneNumber;

    final url = 'https://wa.me/91$formattedPhoneNumber';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp for this number')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(String docId, String name) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900], // Dark grey background
          title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete $name?', style: const TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteUser(docId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name removed')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(String docId) async {
    await FirebaseFirestore.instance.collection('responses').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  centerTitle: true,
  title: const Text('Registered People',
    style: TextStyle(color: Colors.white)),
  backgroundColor: Colors.transparent, // Set background to transparent
  iconTheme: IconThemeData(color: Colors.white), // Keep icons white

  // Additional properties for full transparency (optional)
  elevation: 0.0, // Remove shadow effect
  forceMaterialTransparency: true, // Force transparency (for gestures to pass through)
),

      backgroundColor: Colors.black, // Set screen background to black
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('responses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data', style: TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;
          final totalRegistered = data.length;
          final List<String> names = data.map((doc) => doc['name'] as String).toList();

          if (!hasFetchedGenderCount) {
            _getGenderCount(names);
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade900, Colors.grey.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Registered People: $totalRegistered',
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
                      final docId = doc.id;

                      return Dismissible(
                        key: Key(docId),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            _launchWhatsApp(phone);
                          } else if (direction == DismissDirection.endToStart) {
                            _showDeleteConfirmationDialog(docId, name);
                          }
                        },
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.message, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[850], // Dark grey for the tile background
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
