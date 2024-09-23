import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety_app/data/background/background_services.dart';
import 'package:women_safety_app/data/global/appdata.dart';
import 'package:women_safety_app/res/colors/colors.dart';
import 'package:women_safety_app/res/components/buttons/wide_elevated_button.dart';
import 'package:women_safety_app/res/components/dialogues/video_dialog.dart';
import 'package:women_safety_app/res/components/spacing/vspace.dart';
import 'package:women_safety_app/view_model/bottom_sheat_view_model.dart';
import 'package:women_safety_app/view_model/police_distress_actions/constants.dart';
import 'package:women_safety_app/view_model/police_distress_actions/police_distress_handler.dart';
import 'package:women_safety_app/views/child/accounts/accounts_screen.dart';
import 'package:women_safety_app/views/police/notification_handler.dart';

class PoliceDashboard extends StatefulWidget {
  const PoliceDashboard({super.key});

  @override
  State<PoliceDashboard> createState() => _PoliceDashboardState();
}

class _PoliceDashboardState extends State<PoliceDashboard> {
  BottomSheetControllers locationController = Get.put(BottomSheetControllers());
  PoliceDistressHandler policeDistressHandler = PoliceDistressHandler();
  bool isPoliceAvailable = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async {
    policeData = (await policeDistressHandler.getPoliceInfo(userData["id"]))!;
    await policeDistressHandler.getPoliceInfo(userData["id"]);
    await policeDistressHandler.registerPoliceLocation();
    isPoliceAvailable = policeData["isAvailable"];
    log(policeData.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(userData["imageUrl"]),
          ),
        ),
        title: Text("Hi ${userData["name"]}"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: locationController.updateLocation,
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: primaryColor,
                  ),
                  Obx(
                    () => Text(
                      locationController.realtimeAddress.value.substring(0, 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status:",
                  style: TextStyle(fontSize: size.width * 0.05),
                ),
                Text(
                  isPoliceAvailable.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    color: isPoliceAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Vspace(size: 10),
            isPoliceAvailable
                ? WideElevatedButton(
                    size: size,
                    onCLick: () async {
                      await policeDistressHandler
                          .updateDistressSignalStatus(userData["id"]);
                      policeData = (await policeDistressHandler
                          .getPoliceInfo(userData["id"]))!;
                      isPoliceAvailable = false;
                      setState(() {});
                    },
                    label: "Register as Unavailable",
                    primary: Colors.red,
                  )
                : WideElevatedButton(
                    onCLick: () async {
                      policeData = (await policeDistressHandler
                          .getPoliceInfo(userData["id"]))!;
                      await policeDistressHandler.registerPoliceLocation();
                      isPoliceAvailable = true;
                      setState(() {});
                    },
                    label: "Register as Available",
                    primary: Colors.green,
                    size: size,
                  ),
            const Vspace(size: 10),
            WideElevatedButton(
              size: size,
              onCLick: () {
                Get.to(() => const AccountScreen());
              },
              label: "Edit Profile",
              primary: Colors.black87,
            ),
            const Vspace(size: 40),
            Text(
              "Distress Calls:",
              style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('distressSignals')
                  .where('responderId', isEqualTo: userData["id"])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No distress signals found.',
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                final distressSignals = snapshot.data!.docs;
                if (distressSignals.isNotEmpty) {
                  final tempDistressSignal =
                      distressSignals[0].data() as Map<String, dynamic>;
                  sendNotification(flutterLocalNotificationsPlugin,
                      title: "Distress Signal",
                      body:
                          "${tempDistressSignal["distressCaller"]} needs help!");
                }
                return Column(
                  children: List.generate(
                    distressSignals.length,
                    (index) {
                      final distressSignal =
                          distressSignals[index].data() as Map<String, dynamic>;
                      final distressId = distressSignals[index].id;
                      return Column(
                        children: [
                          ListTile(
                            trailing: IconButton(
                                onPressed: () {
                                  makePhoneCall(
                                    distressSignal['distressCallerPhone']
                                        .toString(),
                                  );
                                },
                                icon: const Icon(Icons.call)),
                            contentPadding: const EdgeInsets.all(0),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  distressSignal['distressCallerImg']),
                            ),
                            title: Text(
                                'Caller: ${distressSignal['distressCaller']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Phone: ${distressSignal['distressCallerPhone']}'),
                                Text(
                                    'Responder: ${distressSignal['responder']}'),
                                Text('Distance: ${calculateDistance(
                                  distressSignal['distressCallerLocation'][1],
                                  distressSignal['distressCallerLocation'][0],
                                  locationController.currentPosition!.latitude,
                                  locationController.currentPosition!.longitude,
                                ).toStringAsFixed(2)} meters'),
                                Text(
                                    'Badge Number: ${distressSignal['responderBadgeNumber']}'),
                                Text(
                                    'Resolved: ${distressSignal['resolved'] ? 'Yes' : 'No'}'),
                                // You might want to use a more sophisticated widget for video display
                              ],
                            ),
                            isThreeLine: true,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                  icon: const Icon(Icons.perm_media),
                                  onPressed: () {
                                    Get.dialog(
                                      VideoDialog(
                                        videoUrl: distressSignal['video'],
                                      ),
                                    );
                                  },
                                  label: const Text("Show Video")),
                              TextButton.icon(
                                  icon: const Icon(Icons.location_on),
                                  onPressed: () {
                                    openGoogleMaps(
                                      distressSignal['distressCallerLocation']
                                          [0],
                                      distressSignal['distressCallerLocation']
                                          [1],
                                    );
                                  },
                                  label: const Text("Navigate")),
                            ],
                          ),
                          WideElevatedButton(
                              size: size,
                              onCLick: () async {
                                Get.dialog(AlertDialog(
                                  title: const Text("Are you sure?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        Get.back();
                                        await markAsResolvedAndDelete(
                                            distressId);
                                      },
                                      child: const Text(
                                        "Yes",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: const Text(
                                        "No",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  ],
                                ));
                              },
                              label: "Mark as Resolved",
                              primary: Colors.red)
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void openGoogleMaps(double latitude, double longitude) async {
  final String googleMapsUrl = 'google.navigation:q=$latitude,$longitude';
  print(googleMapsUrl);

  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else {
    throw 'Could not open Google Maps for navigation.';
  }
}

void makePhoneCall(String phoneNumber) async {
  final String phoneUrl = 'tel:$phoneNumber';

  if (await canLaunch(phoneUrl)) {
    await launch(phoneUrl);
  } else {
    throw 'Could not initiate the call.';
  }
}

Future<void> markAsResolvedAndDelete(String distressId) async {
  final firestore = FirebaseFirestore.instance;

  // Mark as resolved
  await firestore.collection('distressSignals').doc(distressId).update({
    'resolved': true,
  });
  // Delete the document
  await firestore.collection('distressSignals').doc(distressId).delete();
  await PoliceDistressHandler().registerPoliceLocation();
}

double calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  log("Locations: ${[lon1, lat1]} ${[lat2, lon2]}");
  return Geolocator.distanceBetween(lat1, lon1, lon2, lat2);
}
