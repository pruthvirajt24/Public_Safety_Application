import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:women_safety_app/data/global/appdata.dart';
import 'package:women_safety_app/res/colors/colors.dart';
import 'package:women_safety_app/res/components/spacing/vspace.dart';
import 'package:women_safety_app/view_model/bottom_sheat_view_model.dart';
import 'package:women_safety_app/views/distress/distress_screen.dart';
import 'package:women_safety_app/view_model/distress/distress_signal_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BottomSheetControllers locationController = Get.put(BottomSheetControllers());
  DistressSignalHandler distressController = Get.put(DistressSignalHandler());
/*  
  Map Feature
 GoogleMapController? mapController;
  Position? _currentPosition; */

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getCurrentLocation(); Map Feature
    // locationInit();
  }

/* 
  void locationInit() async {
    await locationController.requestPermissions();
    currentLocation = await locationController.getCurrentLocation();
    currentAddress = await locationController.getCurrentAddress();
  } */
  /*  
 Map Feature
 Future<void> _getCurrentLocation() async {
    _currentPosition = await determinePosition();
    setState(() {});
  } */
  final dummyData = [
    {"icon": Icons.person, "title": "Parent", "onTap": () {}},
    {"icon": Icons.shield, "title": "Police", "onTap": () {}},
    {"icon": Icons.fire_truck, "title": "Fire Truck", "onTap": () {}},
    {"icon": Icons.medication, "title": "Ambulance", "onTap": () {}},
  ];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Obx(
      () => locationController.isLoading.value == false
          ? Scaffold(
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
                              locationController.realtimeAddress.value
                                  .substring(0, 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Vspace(size: 30),
                        Text(
                          "Distress Button\nRequest Help",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * 0.07,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Vspace(size: 10),
                        InkWell(
                          onTap: () async {
                            Get.to(() => const DistressScreen());
                          },
                          child: Image.asset(
                            "lib/res/png/distress_button.png",
                            height: 200,
                            // width: 200,
                          ),
                        ),
                        const Vspace(size: 10),
                        Text(
                          "Press the button to send SOS",
                          style: TextStyle(
                            fontSize: size.width * 0.038,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const Vspace(size: 20),
                        SizedBox(
                          height: size.height * 0.45,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: size.height * 0.45 / 4,
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            shrinkWrap: true,
                            itemCount: dummyData.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap:
                                    dummyData[index]["onTap"] as VoidCallback,
                                child: Card(
                                  child: GridTileBar(
                                    leading: Icon(
                                      dummyData[index]["icon"] as IconData,
                                      color: Colors.black,
                                    ),
                                    title: const Text(
                                      "Contact",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_right,
                                      color: primaryColor,
                                    ),
                                    subtitle: Text(
                                      dummyData[index]["title"] as String,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
