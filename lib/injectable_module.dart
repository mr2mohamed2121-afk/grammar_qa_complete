
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

@module
abstract class InjectableModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;

  @lazySingleton
  FirebaseFunctions get functions => FirebaseFunctions.instance;

  @lazySingleton
  InAppPurchase get inAppPurchase => InAppPurchase.instance;

  @lazySingleton
  MobileAds get mobileAds => MobileAds.instance;
}
