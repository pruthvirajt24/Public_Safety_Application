import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:women_safety_app/model/distress_signal_model.dart';

class DistressSignalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'distressSignals';

  // Create or Update Distress Signal
  Future<void> addOrUpdateDistressSignal(
      String distressID, DistressSignal distressSignal) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(distressID)
          .set(distressSignal.toMap(), SetOptions(merge: true));
      print('Distress signal added/updated successfully');
    } catch (e) {
      print('Error adding/updating distress signal: $e');
    }
  }

  Future<void> updateLocation(String distressID, List location) async {
    try {
      await _firestore.collection(collectionPath).doc(distressID).set({
        "distressCallerLocation": [location[1], location[0]]
      }, SetOptions(merge: true));
      print('Distress signal added/updated successfully');
    } catch (e) {
      print('Error adding/updating distress signal: $e');
    }
  }

  // Read Distress Signal
  Future<DistressSignal?> getDistressSignal(String distressID) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collectionPath).doc(distressID).get();
      if (doc.exists) {
        return DistressSignal.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print('No distress signal found for ID: $distressID');
        return null;
      }
    } catch (e) {
      print('Error getting distress signal: $e');
      return null;
    }
  }

  // Delete Distress Signal
  Future<void> deleteDistressSignal(String distressID) async {
    try {
      await _firestore.collection(collectionPath).doc(distressID).delete();
      print('Distress signal deleted successfully');
    } catch (e) {
      print('Error deleting distress signal: $e');
    }
  }

  // Mark Distress Signal as Resolved
  Future<void> markDistressSignalResolved(String distressID) async {
    try {
      await _firestore.collection(collectionPath).doc(distressID).update({
        'resolved': true,
      });
      print('Distress signal marked as resolved');
    } catch (e) {
      print('Error marking distress signal as resolved: $e');
    }
  }

  // Update Video URL
  Future<void> updateVideoUrl(String distressID, String newVideoUrl) async {
    try {
      await _firestore.collection(collectionPath).doc(distressID).update({
        'video': newVideoUrl,
      });
      print('Video URL updated successfully');
    } catch (e) {
      print('Error updating video URL: $e');
    }
  }
}
