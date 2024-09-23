import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

final policeCollection =
    FirebaseFirestore.instance.collection('policeLocations');
final availablePoliceQuery =
    policeCollection.where('isAvailable', isEqualTo: true);
final size = Get.size;
