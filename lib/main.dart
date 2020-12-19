import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dsc_events_app/push_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();



  @override
  Widget build(BuildContext context) {

    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();

    return MaterialApp(
      title: 'DSC Events',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  final ref = FirebaseFirestore.instance.collection('events');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DSC Events'),
      ),
      body: StreamBuilder(
          stream: ref.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return ListView.builder(
                itemCount: snapshot.hasData ? snapshot.data.docs.length : 0,
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () async {
                      var url = snapshot.data.docs[index]
                          .data()['urlToEvent']
                          .toString();
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Card(
                          color: Colors.white24,
                          child: Container(
                            margin: EdgeInsets.all(20),
                            height: 200,
                            //color: Colors.grey[400],
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      snapshot.data.docs[index]
                                          .data()['imageUrl']
                                          .toString(),
                                      height: 80,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  snapshot.data.docs[index].data()['title'],
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  snapshot.data.docs[index]
                                      .data()['description'],
                                  style: TextStyle(fontSize: 13),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  snapshot.data.docs[index].data()['time'],
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}

// Text(snapshot.data.docs[index].data()['title']),
// Text(snapshot.data.docs[index].data()['description']),
// Text(snapshot.data.docs[index].data()['time']),
