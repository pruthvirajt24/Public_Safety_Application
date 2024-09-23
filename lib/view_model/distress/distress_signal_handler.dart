import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:women_safety_app/data/global/appdata.dart';
import 'package:women_safety_app/model/distress_signal_model.dart';
import 'package:women_safety_app/res/utils/utils.dart';
import 'package:women_safety_app/view_model/bottom_sheat_view_model.dart';
import 'package:women_safety_app/view_model/distress/distress_signal_service.dart';
import 'package:women_safety_app/view_model/police_distress_actions/police_distress_handler.dart';

class DistressSignalHandler extends GetxController {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  BottomSheetControllers locationHandler = Get.put(BottomSheetControllers());
  RxString videoStatus = "".obs;

  Future<void> sendDistressSignal(String userId) async {
    Location location = new Location();
    LocationData locationData = await location.getLocation();

    FirebaseFirestore.instance.collection('distressSignals').add({
      'userID': userId,
      'location': GeoPoint(locationData.latitude!, locationData.longitude!),
      'timestamp': Timestamp.now(),
    });

    await findNearestPolice(locationData.latitude!, locationData.longitude!);
  }

  Future findNearestPolice(double userLatitude, double userLongitude) async {
    QuerySnapshot policeSnapshots =
        await FirebaseFirestore.instance.collection('policeLocations').get();

    String? nearestPoliceId;
    double minDistance = double.infinity;

    for (var doc in policeSnapshots.docs) {
      GeoPoint policeLocation = doc['location'];
      bool isAvailable = doc['isAvailable'];

      if (isAvailable) {
        double distance = Geolocator.distanceBetween(
          userLatitude,
          userLongitude,
          policeLocation.latitude,
          policeLocation.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestPoliceId = doc.id;
        }
      }
    }

    if (nearestPoliceId != null) {
      DocumentSnapshot policeDetails = await FirebaseFirestore.instance
          .collection('policeLocations')
          .doc(nearestPoliceId)
          .get();
      final policeData = policeDetails.data();
      final tempPoliceData = policeData as Map<String, dynamic>;

      await DistressSignalService().addOrUpdateDistressSignal(
        userData["id"],
        DistressSignal(
          distressCaller: userData["name"],
          distressCallerLocation: [userLongitude, userLatitude],
          responder: tempPoliceData['name'],
          responderId: tempPoliceData["id"],
          distressCallerPhone: int.parse(userData["phone"]),
          responderBadgeNumber: tempPoliceData["badgeNumber"],
          video: "",
          resolved: false,
          distressCallerId: userData["id"],
          distressCallerImg: userData['imageUrl'],
        ),
      );
      await PoliceDistressHandler().updateDistressSignalStatus(nearestPoliceId);
      return policeData;
      // await sendNotificationToPolice(nearestPoliceId);
    } else {
      return {"status": "no police found"};
    }
  }

  /* Video Recording and Uploading Feature starts- */
  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0], // Select the first camera available (typically rear camera)
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _cameraController.initialize();
  }

  Future<File?> startRecording() async {
    try {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Videos';
      await Directory(dirPath).create(recursive: true);
      final String filePath =
          '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _cameraController.startVideoRecording();
      return File(filePath);
    } catch (e) {
      print('Error while starting video recording: $e');
      return null;
    }
  }

  Future<File?> stopRecording() async {
    try {
      XFile videoFile = await _cameraController.stopVideoRecording();
      return File(videoFile.path);
    } catch (e) {
      print('Error while stopping video recording: $e');
      return null;
    }
  }

  Future<String?> uploadVideoToFirebase(File videoFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = videoFile.path.split('/').last;

      Reference ref = storage.ref().child('videos/$fileName');
      UploadTask uploadTask = ref.putFile(videoFile);

      await uploadTask.whenComplete(() => log('Upload complete'));
      String downloadUrl = await ref.getDownloadURL();
      log('Video uploaded. Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('Error while uploading video to Firebase: $e');
      return null;
    }
  }

  Future<String> recordAndUploadVideo(int durationInSecs) async {
    await initializeCamera();

    videoStatus.value = "Recording Video...";
    File? videoFile = await startRecording();
    log("recording video");
    // Set the recording duration (e.g., 10 seconds)
    await Future.delayed(Duration(seconds: durationInSecs));

    File? recordedVideo = await stopRecording();
    videoStatus.value = "Video Recorded, Uploading Now...";
    log("recording stopped uploading now");

    if (recordedVideo != null) {
      videoStatus.value = "Sending video to the officer...";
      final vidLink = await uploadVideoToFirebase(recordedVideo);
      videoStatus.value = "Video sent to Officer.";

      return vidLink!;
    } else {
      videoStatus.value = "Error sending video.";
      showError("There was a problem sending your video");
    }
    log("video uploaded");
    _cameraController.dispose();
    return null!;
  }
  /* Video Recording and Uploading Feature ends- */
}
