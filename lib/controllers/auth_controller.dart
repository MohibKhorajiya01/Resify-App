import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<User?> _user;
  Rx<User?> get user => _user;
  
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    
    // Listen for auth state changes to handle logout automatically
    ever(_user, (User? user) {
      if (user == null && Get.currentRoute != '/login' && Get.currentRoute != '/splash' && Get.currentRoute != '/onboarding') {
        Get.offAllNamed('/login');
      }
    });
  }

  void handleInitialRouting() {
    final user = auth.currentUser;
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      if (!user.emailVerified) {
        Get.offAllNamed('/verify_email');
      } else {
        ensureFirestoreData(user);
        Get.offAllNamed('/dashboard');
      }
    }
  }

  Future<void> ensureFirestoreData(User user, {String? name}) async {
    try {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await firestore.collection('users').doc(user.uid).set({
          'name': name ?? user.displayName ?? 'Resify User',
          'email': user.email,
          'uid': user.uid,
          'createdAt': DateTime.now(),
        });
      } else {
        final firestoreName = doc.data()?['name'] as String?;
        if ((user.displayName == null || user.displayName!.isEmpty) && firestoreName != null && firestoreName.isNotEmpty) {
          await user.updateDisplayName(firestoreName);
          await user.reload();
          _user.value = auth.currentUser;
        }
      }
    } catch (e) {
      // Ignore firestore errors so it doesn't block login
      debugPrint("Firestore Error: $e");
    }
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name so we can save it later
      await cred.user!.updateDisplayName(name);
      await cred.user!.reload();
      _user.value = auth.currentUser;

      // Go to verify email. VerifyEmailScreen will save to Firestore upon success.
      Get.offAllNamed('/verify_email');
      return null;

    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'Bhai, ye email pehle se Firebase Authentication me register hai! Kripya niche "Login" par dabayein aur login karein, naya account mat banayein.';
      } else if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }

      return message;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!cred.user!.emailVerified) {
        Get.offAllNamed('/verify_email');
      } else {
        await ensureFirestoreData(cred.user!);
        Get.offAllNamed('/dashboard');
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Invalid email or password. Please try again.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      } else if (e.message != null) {
        message = e.message!;
      }
      
      return message;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> updateProfileName(String newName) async {
    try {
      isLoading.value = true;
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(newName);
        await currentUser.reload();
        _user.value = auth.currentUser;
        
        await firestore.collection('users').doc(currentUser.uid).update({
          'name': newName,
        });
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await auth.signOut();
  }
}
