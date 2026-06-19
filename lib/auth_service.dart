
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserData(firebaseUser.uid);
    });
  }

  Future<User?> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = uid;
      return User.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw Exception('فشل تسجيل الدخول');
      }

      final user = await _getUserData(result.user!.uid);
      if (user == null) {
        throw Exception('لم يتم العثور على بيانات المستخدم');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw Exception('فشل إنشاء الحساب');
      }

      final user = User(
        id: result.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  String _handleAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لم يتم العثور على حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      default:
        return 'حدث خطأ ما، يرجى المحاولة مرة أخرى';
    }
  }
}
