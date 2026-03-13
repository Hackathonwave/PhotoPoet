import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NewsletterService {
  static FirebaseFirestore? _firestoreInstance;
  static const String _collectionName = 'subscribers';

  static FirebaseFirestore get _firestore {
    try {
      return _firestoreInstance ??= FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('[NewsletterService] Firestore instance access failed: $e');
      throw 'Firebase not initialized. Please check your configuration.';
    }
  }

  /// Subscribes an email to the newsletter by storing it in Cloud Firestore.
  static Future<void> subscribe(String email) async {
    try {
      final String platform = kIsWeb 
          ? 'web' 
          : (defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios');

      await _firestore.collection(_collectionName).add({
        'email': email.trim().toLowerCase(),
        'subscribedAt': FieldValue.serverTimestamp(),
        'platform': platform,
        'source': 'photo_poet_app',
      });
      
      debugPrint('[NewsletterService] Successfully subscribed: $email');
    } catch (e) {
      debugPrint('[NewsletterService] Subscription error: $e');
      rethrow;
    }
  }
}
