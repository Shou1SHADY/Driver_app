import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

class DriverUser {
  String id;
  String username;
  String password;
  String image;

  // Constructor
  DriverUser({
    required this.id,
    required this.username,
    required this.password,
    required this.image,
  });

  // Local database methods

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'image': image,
    };
  }

  factory DriverUser.fromMap(Map<String, dynamic> map) {
    return DriverUser(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      image: map['image'],
    );
  }

  // Firebase methods

  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<User?> registerWithFirebase({
    required String username,
    required String password,
    required String image,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: username,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'password': password,
          'uid': user.uid,
          'image': image,
        });

        return user;
      }

      return null;
    } catch (e) {
      print('Error registering with Firebase: $e');
      return null;
    }
  }

  static Future<User?> signInWithFirebase({
    required String username,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print('Error signing in with Firebase: $e');
      return null;
    }
  }

  static Future<void> signOutFromFirebase() async {
    await _auth.signOut();
  }

  static Future<String?> uploadImageToFirebase(String imagePath) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      print(userId);
      Reference storageReference =
          _storage.ref().child('user_images').child('$userId.jpg');

      File imageFile = File(imagePath);

      UploadTask uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() => null);

      String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  Future<void> saveToLocalDatabase() async {
    final Database db = await _getDatabase();
    await db.insert(
      'driver_users',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<DriverUser?> getFromLocalDatabase(String userId) async {
    final Database db = await _getDatabase();
    List<Map<String, dynamic>> maps = await db.query(
      'driver_users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return DriverUser.fromMap(maps.first);
    } else {
      return null;
    }
  }

  static Future<void> deleteDriverUser(String userId) async {
    final Database db = await _getDatabase();
    await db.delete(
      'driver_users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  static Future<Database> _getDatabase() async {
    return openDatabase(
      'driver_users.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE driver_users (
            id TEXT PRIMARY KEY,
            username TEXT,
            password TEXT,
            image TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveToFirebaseAndLocal({
    required String username,
    required String password,
    required String imagePath,
  }) async {
    String? imageUrl = await uploadImageToFirebase(imagePath);

    if (imageUrl != null) {
      User? user = await registerWithFirebase(
        username: username,
        password: password,
        image: imageUrl,
      );

      if (user != null) {
        await saveToLocalDatabase();
      }
    }
  }

  static Future<DriverUser?> signInWithFirebaseAndLocal({
    required String username,
    required String password,
  }) async {
    User? user =
        await signInWithFirebase(username: username, password: password);

    if (user != null) {
      return getFromLocalDatabase(user.uid);
    } else {
      return null;
    }
  }

  static Future<void> signOutAndDeleteLocal() async {
    await signOutFromFirebase();

    String userId = _auth.currentUser?.uid ?? '';
    await deleteDriverUser(userId);
  }

  Future<void> updateFirebaseAndLocal({
    required String username,
    required String password,
    required String imagePath,
  }) async {
    String? imageUrl = await uploadImageToFirebase(imagePath);

    if (imageUrl != null) {
      await _auth.currentUser?.updateEmail(username);
      await _auth.currentUser?.updatePassword(password);

      await _firestore.collection('users').doc(id).update({
        'username': username,
        'image': imageUrl,
      });

      await saveToLocalDatabase();
    }
  }

  static Future<void> updateUserProfile(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'image': imageUrl,
      });
    } catch (e) {
      print('Error updating user profile: $e');
      // Handle the error as needed
    }
  }

  static Future<String?> getProfilePicture(String userId) async {
    try {
      // Reference to the user's document in the Firestore collection
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the user's document snapshot
      DocumentSnapshot userSnapshot = await userDocRef.get();

      // Check if the user document exists
      if (userSnapshot.exists) {
        // Get the 'image' field from the document data
        // dynamic image = userSnapshot.data()?['image'] ;
        dynamic image =
            (userSnapshot.data() as Map<String, dynamic>?)?['image'];

        // Return the profile picture URL if it exists
        return image != null ? image.toString() : null;
      } else {
        // Handle the case where the user document doesn't exist
        return null;
      }
    } catch (e) {
      // Handle errors, e.g., Firestore connection issues
      print('Error getting profile picture: $e');
      return null;
    }
  }
}
