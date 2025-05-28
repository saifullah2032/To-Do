import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/task_model.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser!.uid;

  Stream<List<Task>> getTasks() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .add(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(id)
        .update({'isCompleted': !isCompleted});
  }

  Future<void> toggleTaskImportance(String id, bool isImportant) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(id)
        .update({'isImportant': !isImportant});
  }

  Future<void> updateTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }
}
