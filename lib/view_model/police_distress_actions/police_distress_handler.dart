import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:women_safety_app/data/global/appdata.dart';
import 'package:women_safety_app/res/utils/utils.dart';

class PoliceDistressHandler {
  Future<void> registerPoliceLocation() async {
    // Use Geolocator to get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    // Store police location data in Firestore
    FirebaseFirestore.instance
        .collection('policeLocations')
        .doc(userData["id"])
        .set({
      'name': userData['name'],
      'phone': userData['phone'],
      'email': userData['email'],
      'badgeNumber': userData['badgeNumber'],
      'imageUrl': userData['imageUrl'],
      'id': userData['id'],
      'location': GeoPoint(position.latitude, position.longitude),
      'isAvailable': true,
    });
    log("Police location registered");
  }

  Future<Map<String, dynamic>?> getPoliceInfo(String policeId) async {
    try {
      // Retrieve the document from Firestore
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('policeLocations')
          .doc(policeId)
          .get();

      if (documentSnapshot.exists) {
        // Convert the document data to a Map and return it
        Map<String, dynamic> policeData =
            documentSnapshot.data() as Map<String, dynamic>;
        log("Police data retrieved: $policeData");
        return policeData;
      } else {
        log("No police data found for ID: $policeId");
        return null;
      }
    } catch (e) {
      log("Failed to retrieve police data: $e");
      return null;
    }
  }

  Future<void> updateDistressSignalStatus(String policeId) async {
    /* Marks Police as unavailable */
    /*  FirebaseFirestore.instance
        .collection('distressSignals')
        .doc(signalId)
        .update({
      'status': 'Responded',
      'responseTimestamp': Timestamp.now(),
    }); */

    // String policeId = userData["id"];
    FirebaseFirestore.instance
        .collection('policeLocations')
        .doc(policeId)
        .update({
      'isAvailable': false,
    });
    log("marked as unavailable");
  }

  Future<String> getAddressbyCoords(double longitude, double latitude) async {
    String currentAddress = "";
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress =
            "${place.locality}, ${place.street}, ${place.postalCode}, ${place.name}, ${place.subAdministrativeArea}";
        return currentAddress;
      } else {
        // Handle case where no results were found
        showError('No address found for the given coordinates.');
      }
    } catch (e) {
      // Handle any other errors that may occur
      showError('Failed to get current address: $e');
    }
    return "";
  }
}
