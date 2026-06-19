
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../core/errors/exceptions.dart';

@lazySingleton
class FirestoreOfflineService {
  final FirebaseFirestore _firestore;

  FirestoreOfflineService(this._firestore) {
    _initializeOffline();
  }

  Future<void> _initializeOffline() async {
    try {
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );

      // Set cache size to 100 MB
      _firestore.settings = const Settings(
        cacheSizeBytes: 100 * 1024 * 1024, // 100 MB
        persistenceEnabled: true,
      );

      print('✅ Firestore offline persistence enabled');
    } catch (e) {
      print('⚠️ Firestore persistence error: $e');
    }
  }

  Future<void> clearCache() async {
    await _firestore.clearPersistence();
  }

  Future<void> enableNetwork() async {
    await _firestore.enableNetwork();
  }

  Future<void> disableNetwork() async {
    await _firestore.disableNetwork();
  }

  bool get isOnline => true; // Check connectivity separately
}
