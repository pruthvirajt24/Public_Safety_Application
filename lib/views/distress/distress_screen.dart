import 'dart:async';
import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety_app/data/global/appdata.dart';
import 'package:women_safety_app/res/components/buttons/wide_elevated_button.dart';
import 'package:women_safety_app/res/components/spacing/vspace.dart';
import 'package:women_safety_app/view_model/bottom_sheat_view_model.dart';
import 'package:women_safety_app/view_model/distress/distress_signal_handler.dart';
import 'package:women_safety_app/view_model/distress/distress_signal_service.dart';
import 'package:women_safety_app/view_model/distress/safety_tips.dart';
import 'package:women_safety_app/view_model/police_distress_actions/constants.dart';
import 'package:women_safety_app/view_model/police_distress_actions/police_distress_handler.dart';

class DistressScreen extends StatefulWidget {
  const DistressScreen({super.key});

  @override
  State<DistressScreen> createState() => _DistressScreenState();
}

class _DistressScreenState extends State<DistressScreen> {
  RxBool isLoading = false.obs;
  dynamic policeInfo;
  String policeLocation = "";
  String videoUrl = "";
  DistressSignalHandler distressSignalHandler =
      Get.put(DistressSignalHandler());
  BottomSheetControllers locationController = Get.put(BottomSheetControllers());
  PoliceDistressHandler policeDistressHandler =
      Get.put(PoliceDistressHandler());
  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handleDistress();
    sendVideo();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        log("Updating Location...");
        locationController.getCurrentLocation();
        DistressSignalService().updateLocation(userData["id"], [
          locationController.currentPosition!.longitude,
          locationController.currentPosition!.latitude
        ]);
      },
    );
  }

  sendVideo() async {
    videoUrl = await distressSignalHandler.recordAndUploadVideo(10);
    DistressSignalService().updateVideoUrl(userData["id"], videoUrl);
  }

  handleDistress() async {
    isLoading.value = true;
    policeInfo = await DistressSignalHandler().findNearestPolice(
        locationController.currentPosition!.latitude,
        locationController.currentPosition!.longitude);
    policeLocation = await policeDistressHandler.getAddressbyCoords(
        policeInfo["location"].longitude, policeInfo["location"].latitude);
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => isLoading.value
          ? Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      "lib/res/lottie/scanning.json",
                    ),
                    Text(
                      "Looking for officers...",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Scaffold(
              appBar: AppBar(
                title: const Text("Distress Signal"),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Vspace(size: 30),
                      Text(
                        "Help is on the way!",
                        style: TextStyle(
                          fontSize: size.width * 0.07,
                          // fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      /*  Lottie.asset(
                        "lib/res/lottie/police_vehicle.json",
                        fit: BoxFit.fitHeight,
                      ), */
                      const Vspace(size: 50),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Officer Details:",
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            // fontFamily: "Montserrat",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(policeInfo['imageUrl']),
                            ),
                            title: Text(policeInfo['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${policeInfo['phone']}"),
                                Text("${policeInfo['badgeNumber']}"),
                                Text(policeLocation),
                              ],
                            ),
                            // isThreeLine: true,
                          ),
                          const Vspace(size: 10),
                          WideElevatedButton(
                            size: size,
                            onCLick: () {
                              _callNumber(policeInfo["phone"]);
                            },
                            label: "Call Now",
                            primary: Colors.green,
                          ),
                        ],
                      ),
                      const Vspace(size: 20),
                      DottedBorder(
                        color: Colors.green,
                        strokeWidth: 2,
                        dashPattern: const [6, 3],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Obx(
                            () => Text(
                              distressSignalHandler.videoStatus.value,
                              style: TextStyle(fontSize: size.width * 0.05),
                            ),
                          ),
                        ),
                      ),
                      const Vspace(size: 40),
                      SafetyTips(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
}

void _callNumber(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  if (await canLaunch(launchUri.toString())) {
    await launch(launchUri.toString());
  } else {
    throw 'Could not launch $phoneNumber';
  }
}
