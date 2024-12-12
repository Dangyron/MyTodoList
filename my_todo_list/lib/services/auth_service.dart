import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_todo_list/services/data_service.dart';
import 'package:my_todo_list/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await _saveLoggedIn(true);

      final syncService = SyncService();
      await syncService.syncToFirebase();
      await syncService.syncFromFirebase();
      return result.user;
    } catch (error) {
      log(error.toString());
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _saveLoggedIn(true);

      await SyncService().syncToFirebase();
      return result.user;
    } catch (error) {
      log(error.toString());
      return null;
    }
  }

  Future<User?> signInAsGuest() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      await _saveLoggedIn(true);
      return result.user;
    } catch (error) {
      log(error.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _clearData();
    await _saveLoggedIn(false);
  }

  Future<void> _saveLoggedIn(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.isLoggedInPref, status);
  }

  Future<void> _clearData() async {
    DataService().clearLocalData();
  }
}
