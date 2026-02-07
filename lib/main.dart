import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snack Store',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Snack Store 🍭'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _snackNameCtrl = TextEditingController();
  final _snackTypeCtrl = TextEditingController();
  final _snackPriceCtrl = TextEditingController();

  void addSnack() async {
    if (_snackNameCtrl.text.isEmpty ||
        _snackTypeCtrl.text.isEmpty ||
        _snackPriceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรอกข้อมูลไม่ครบ")));
      return;
    }

    await FirebaseFirestore.instance.collection("snacks").add({
      "snackName": _snackNameCtrl.text,
      "snackType": _snackTypeCtrl.text,
      "snackPrice": _snackPriceCtrl.text,
    });

    _snackNameCtrl.clear();
    _snackTypeCtrl.clear();
    _snackPriceCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Column(
        children: [
          // ===== FORM =====
          Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "เพิ่มรายการขนม 🍩",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _snackNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'ชื่อขนม',
                        prefixIcon: Icon(Icons.cookie),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    TextField(
                      controller: _snackTypeCtrl,
                      decoration: InputDecoration(
                        labelText: 'ประเภทขนม',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    TextField(
                      controller: _snackPriceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'ราคา (บาท)',
                        prefixIcon:  Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        label: Text("บันทึก"),
                        onPressed: addSnack,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== LIST =====
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("snacks")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(child: Text("ยังไม่มีรายการขนม 🍬"));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final snack = docs[index].data() as Map<String, dynamic>;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SnackDetailPage(snack: snack),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fastfood,
                                size: 40,
                                color: Colors.deepPurple,
                              ),
                              SizedBox(height: 8),
                              Text(
                                snack["snackName"],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${snack["snackPrice"]} บาท",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SnackDetailPage extends StatelessWidget {
  final Map<String, dynamic> snack;
  const SnackDetailPage({super.key, required this.snack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("รายละเอียดขนม")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.fastfood,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  snack['snackName'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text("ประเภท: ${snack['snackType']}"),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.attach_money),
                    SizedBox(width: 8),
                    Text(
                      "ราคา: ${snack['snackPrice']} บาท",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
