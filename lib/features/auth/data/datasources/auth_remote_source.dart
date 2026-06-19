
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/exceptions.dart';
import '../entities/user_entity.dart';

@injectable
class AuthRemoteSource {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteSource(this._auth, this._firestore);

  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserData(firebaseUser.uid);
    });
  }

  Future<UserEntity?> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserEntity(
        id: uid,
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        isAdmin: data['isAdmin'] ?? false,
        isPremium: data['isPremium'] ?? false,
        photoUrl: data['photoUrl'],
        createdAt: DateTime.parse(data['createdAt']),
        premiumPlan: data['premiumPlan'],
        premiumExpiresAt: data['premiumExpiresAt'] != null
            ? DateTime.parse(data['premiumExpiresAt'])
            : null,
        availableCards: data['availableCards'],
      );
    } catch (e) {
      return null;
    }
  }

  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw AuthException('فشل تسجيل الدخول');
      }

      final user = await _getUserData(result.user!.uid);
      if (user == null) {
        throw AuthException('لم يتم العثور على بيانات المستخدم');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<UserEntity> signUpWithEmailAndPassword({
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
        throw AuthException('فشل إنشاء الحساب');
      }

      final user = UserEntity(
        id: result.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'isAdmin': false,
        'isPremium': false,
        'createdAt': user.createdAt.toIso8601String(),
      });

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _getUserData(user.uid);
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
