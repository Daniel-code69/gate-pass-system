import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../main.dart' show firebaseAvailable;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const _boxName = 'users';
  AppUser? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AppUser? get currentUser => _currentUser;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  DatabaseReference get _usersFb =>
      FirebaseDatabase.instance.ref().child('users');
  DatabaseReference get _fbUidRef =>
      FirebaseDatabase.instance.ref().child('fbUid_to_userId');

  DatabaseReference get _usersByFbUidRef =>
      FirebaseDatabase.instance.ref().child('users_by_fbUid');

  Future<void> _saveUserToFb(AppUser user) async {
    if (!firebaseAvailable) return;
    try {
      await _usersFb.child(user.id).set(user.toMap());
    } catch (_) {}
    if (user.fbUid != null) {
      try {
        await _fbUidRef.child(user.fbUid!).set(user.id);
      } catch (_) {}
      try {
        await _usersByFbUidRef.child(user.fbUid!).set(user.toMap());
      } catch (_) {}
    }
  }

  Future<AppUser?> _findOrRestoreUser(String fbUid, String email) async {
    if (!firebaseAvailable) return null;

    // 1. Direct read from /users_by_fbUid/{fbUid}
    //    Works with standard per-user rules ($uid === auth.uid)
    try {
      final snap = await _usersByFbUidRef.child(fbUid).get();
      if (snap.exists) {
        return AppUser.fromMap(
            Map<String, dynamic>.from(snap.value as Map));
      }
    } catch (_) {}

    // 2. Read /fbUid_to_userId/{fbUid} → /users/{uuid}
    try {
      final mapSnap = await _fbUidRef.child(fbUid).get();
      if (mapSnap.exists) {
        final uuid = mapSnap.value as String;
        final userSnap = await _usersFb.child(uuid).get();
        if (userSnap.exists) {
          return AppUser.fromMap(
              Map<String, dynamic>.from(userSnap.value as Map));
        }
      }
    } catch (_) {}

    // 3. Query /users by email (requires .indexOn or permissive rules)
    try {
      final snap = await _usersFb.orderByChild('email').equalTo(email).get();
      if (snap.exists) {
        for (final child in snap.children) {
          return AppUser.fromMap(
              Map<String, dynamic>.from(child.value as Map));
        }
      }
    } catch (_) {}

    // 4. Download all /users and filter locally (requires .read on /users)
    try {
      final snap = await _usersFb.get();
      if (snap.exists) {
        for (final child in snap.children) {
          final data = child.value as Map?;
          if (data != null && data['email'] == email) {
            return AppUser.fromMap(Map<String, dynamic>.from(data));
          }
        }
      }
    } catch (_) {}

    return null;
  }

  Future<void> seedDemoUsers() async {
    final box = await Hive.openBox<Map>(_boxName);
    if (box.isEmpty) {
      final users = [
        AppUser(
          id: const Uuid().v4(),
          name: 'Mr. Sharma',
          email: 'teacher@college.com',
          password: 'password',
          role: 'teacher',
        ),
        AppUser(
          id: const Uuid().v4(),
          name: 'Mr. Khan',
          email: 'security@college.com',
          password: 'password',
          role: 'security',
        ),
      ];
      for (final u in users) {
        await box.add(u.toMap());
      }
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final box = await Hive.openBox<Map>(_boxName);
    final exists = box.values.cast<Map>().any((m) => m['email'] == email.trim());
    if (exists) {
      return {'ok': false, 'message': 'An account with this email already exists.'};
    }

    String? fbUid;
    if (firebaseAvailable) {
      try {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        fbUid = cred.user?.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          try {
            final cred = await _auth.signInWithEmailAndPassword(
              email: email.trim(),
              password: password,
            );
            fbUid = cred.user?.uid;
          } catch (_) {
            return {'ok': false, 'message': 'This email is already registered.'};
          }
        } else {
          return {'ok': false, 'message': e.message ?? 'Sign up failed.'};
        }
      }

      // Reinstall - user exists in Firebase Auth but not in Hive
      if (fbUid != null) {
        final recovered = await _findOrRestoreUser(fbUid, email.trim());
        if (recovered != null) {
          final restored = AppUser(
            id: recovered.id,
            name: recovered.name,
            email: recovered.email,
            password: password,
            role: recovered.role,
            fbUid: fbUid,
          );
          await box.add(restored.toMap());
          await _saveUserToFb(restored);
          _currentUser = restored;
          return {'ok': true, 'role': restored.role, 'user': restored};
        }
      }
    }

    final user = AppUser(
      id: const Uuid().v4(),
      name: name.trim(),
      email: email.trim(),
      password: password,
      role: role,
      fbUid: fbUid,
    );
    await box.add(user.toMap());
    await _saveUserToFb(user);
    _currentUser = user;
    return {'ok': true, 'role': role, 'user': user};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final box = await Hive.openBox<Map>(_boxName);
    for (final data in box.values) {
      final u = AppUser.fromMap(Map<String, dynamic>.from(data));
      if (u.email == email.trim() && u.password == password) {
        _currentUser = u;
        return {'ok': true, 'role': u.role, 'user': u};
      }
    }

    // Hive miss — try Firebase Auth + RTDB (handles reinstall)
    if (firebaseAvailable) {
      try {
        final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUid = cred.user?.uid;
        if (fbUid != null) {
          final recovered = await _findOrRestoreUser(fbUid, email.trim());
          if (recovered != null) {
            final restored = AppUser(
              id: recovered.id,
              name: recovered.name,
              email: recovered.email,
              password: password,
              role: recovered.role,
              fbUid: fbUid,
            );
            await box.add(restored.toMap());
            await _saveUserToFb(restored);
            _currentUser = restored;
            return {'ok': true, 'role': restored.role, 'user': restored};
          }
        }
      } on FirebaseAuthException catch (e) {
        return {
          'ok': false,
          'message': e.message ?? 'Invalid email or password.',
        };
      } catch (_) {
        return {
          'ok': false,
          'message': 'Could not connect to server. Check your internet connection.',
        };
      }
    }

    return {'ok': false, 'message': 'Invalid email or password.'};
  }

  Future<Map<String, dynamic>> signInWithGoogle(
      {String? nameOverride, String? emailOverride, String? roleOverride}) async {
    if (firebaseAvailable) {
      try {
        await _auth.signOut();
      } catch (_) {}
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      try {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return {'ok': false, 'message': 'Google sign-in cancelled.'};
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        final fbUser = userCredential.user;
        if (fbUser == null) {
          return {'ok': false, 'message': 'Google sign-in failed.'};
        }

        final fbUid = fbUser.uid;
        final String email;
        if (fbUser.email != null && fbUser.email!.isNotEmpty) {
          email = fbUser.email!;
        } else if (googleUser.email.isNotEmpty) {
          email = googleUser.email;
        } else {
          return {'ok': false, 'message': 'Could not retrieve email from Google account.'};
        }
        final name = fbUser.displayName ?? googleUser.displayName ?? '';

        final box = await Hive.openBox<Map>(_boxName);

        // 1. Find user by email in Hive
        for (final key in box.keys) {
          final m = box.get(key);
          if (m != null && m['email'] == email) {
            if (m['fbUid'] == null && fbUid.isNotEmpty) {
              m['fbUid'] = fbUid;
              await box.put(key, m);
            }
            final u = AppUser.fromMap(Map<String, dynamic>.from(m));
            _currentUser = u;
            await _saveUserToFb(u);
            return {'ok': true, 'role': u.role, 'user': u};
          }
        }

        // 2. Try recovery from Firebase RTDB (handles reinstall)
        final recovered = await _findOrRestoreUser(fbUid, email);
        if (recovered != null) {
          final restored = AppUser(
            id: recovered.id,
            name: recovered.name,
            email: recovered.email,
            password: recovered.password,
            role: recovered.role,
            fbUid: fbUid,
          );
          await box.add(restored.toMap());
          await _saveUserToFb(restored);
          _currentUser = restored;
          return {'ok': true, 'role': restored.role, 'user': restored};
        }

        // 3. Legacy migration: empty email user (previous bug)
        for (final key in box.keys) {
          final m = box.get(key);
          if (m != null && (m['email'] as String? ?? '').isEmpty) {
            m['email'] = email;
            m['name'] = name;
            m['fbUid'] = fbUid;
            await box.put(key, m);
            _currentUser = AppUser.fromMap(Map<String, dynamic>.from(m));
            return {'ok': true, 'role': _currentUser!.role, 'user': _currentUser};
          }
        }

        return {'needsRoleSelection': true, 'name': name, 'email': email};
      } catch (e) {
        return {
          'ok': false,
          'message': 'Google sign-in failed: ${e.toString().replaceFirst('Exception: ', '')}.'
        };
      }
    }

    return _findOrCreateUser(
        nameOverride ?? 'Google User', emailOverride ?? 'google@user.com',
        roleOverride ?? 'teacher');
  }

  Future<Map<String, dynamic>> completeGoogleSignUp({
    required String name,
    required String email,
    required String role,
  }) async {
    String? fbUid;
    if (firebaseAvailable) {
      try {
        fbUid = _auth.currentUser?.uid;
      } catch (_) {}
    }
    final user = AppUser(
      id: const Uuid().v4(),
      name: name.trim(),
      email: email.trim(),
      password: '',
      role: role,
      fbUid: fbUid,
    );
    final box = await Hive.openBox<Map>(_boxName);
    await box.add(user.toMap());
    await _saveUserToFb(user);
    _currentUser = user;
    return {'ok': true, 'role': role, 'user': user};
  }

  Future<Map<String, dynamic>> _findOrCreateUser(
      String name, String email, String role) async {
    final box = await Hive.openBox<Map>(_boxName);
    final existing = box.values.cast<Map>().where((m) => m['email'] == email);
    if (existing.isNotEmpty) {
      _currentUser =
          AppUser.fromMap(Map<String, dynamic>.from(existing.first));
      return {'ok': true, 'role': _currentUser!.role, 'user': _currentUser};
    }

    // Legacy user from previous bug where email was null on Google sign-in
    if (email.isNotEmpty) {
      final legacy = box.values.cast<Map>().toList();
      final legacyIndex = legacy.indexWhere(
          (m) => (m['email'] as String? ?? '').isEmpty);
      if (legacyIndex >= 0) {
        final legacyMap = Map<String, dynamic>.from(legacy[legacyIndex]);
        final legacyKey = box.keys.elementAt(legacyIndex);
        legacyMap['email'] = email;
        legacyMap['name'] = name;
        await box.put(legacyKey, legacyMap);
        _currentUser = AppUser.fromMap(legacyMap);
        return {'ok': true, 'role': _currentUser!.role, 'user': _currentUser};
      }
    }

    final user = AppUser(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: '',
      role: role,
    );
    await box.add(user.toMap());
    await _saveUserToFb(user);
    _currentUser = user;
    return {'ok': true, 'role': role, 'user': user};
  }

  Future<void> logout() async {
    _currentUser = null;
    if (firebaseAvailable) {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      await _auth.signOut();
    }
  }
}
