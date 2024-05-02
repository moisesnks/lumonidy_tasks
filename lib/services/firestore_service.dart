// Path: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumonidy_tasks/models/user.dart';
import 'package:lumonidy_tasks/models/task.dart';

class FirestoreResult {
  final bool success;
  final String message;

  FirestoreResult(this.success, this.message);
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función que obtiene todos los usuarios de la colección 'users'
  Future<List<User>> getUsers() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('users').get();

      return querySnapshot.docs.map((doc) => User.fromDocument(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Función que permite actualizar una tarea en la colección 'tasks' y en los usuarios asignados
  Future<FirestoreResult> updateTask(Task task) async {
    try {
      // Actualizar la tarea
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());

      // Actualizar cada usuario asignado a la tarea
      for (DocumentReference userRef in task.assignedTo) {
        await userRef.update({
          'assignedTasks': FieldValue.arrayUnion(
              [_firestore.collection('tasks').doc(task.id)])
        });
      }

      return FirestoreResult(true, 'Tarea actualizada exitosamente');
    } catch (e) {
      return FirestoreResult(false, 'Error actualizando la tarea: $e');
    }
  }

  // Función que elimina una tarea de la colección 'tasks' y de los usuarios asignados
  Future<FirestoreResult> deleteTask(String taskId) async {
    try {
      // Obtener la tarea
      DocumentSnapshot taskDoc =
          await _firestore.collection('tasks').doc(taskId).get();
      if (!taskDoc.exists) {
        return FirestoreResult(false, 'La tarea no existe');
      }

      // Eliminar la tarea
      await _firestore.collection('tasks').doc(taskId).delete();

      // Eliminar la tarea de los usuarios asignados
      List<DocumentReference> userRefs =
          List<DocumentReference>.from(taskDoc['assignedUsers']);
      for (DocumentReference userRef in userRefs) {
        await userRef.update({
          'assignedTasks': FieldValue.arrayRemove(
              [_firestore.collection('tasks').doc(taskId)])
        });
      }

      return FirestoreResult(true, 'Tarea eliminada exitosamente');
    } catch (e) {
      return FirestoreResult(false, 'Error eliminando la tarea: $e');
    }
  }

  // Función que desasigna un usuario de una tarea
  Future<FirestoreResult> unassignUserFromTask(Task task, User user) async {
    try {
      // Desasignar la tarea del usuario
      await _firestore.collection('users').doc(user.id).update({
        'assignedTasks': FieldValue.arrayRemove(
            [_firestore.collection('tasks').doc(task.id)])
      });

      // Desasignar el usuario de la tarea
      await _firestore.collection('tasks').doc(task.id).update({
        'assignedUsers': FieldValue.arrayRemove(
            [_firestore.collection('users').doc(user.id)])
      });

      return FirestoreResult(true, 'Usuario desasignado de la tarea');
    } catch (e) {
      return FirestoreResult(
          false, 'Error desasignando usuario de la tarea: $e');
    }
  }

  // Función que obtiene todas las tareas de la colección 'tasks'
  Future<List<Task>> getTasks() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('tasks').get();

      return querySnapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Función que asigna usuarios a una tarea,
  // una tarea puede tener varios usuarios asignados
  Future<FirestoreResult> assignUsersToTask(Task task, List<User> users) async {
    try {
      // Obtener referencias a los documentos de usuarios asignados
      List<DocumentReference> userRefs = users
          .map((user) => _firestore.collection('users').doc(user.id))
          .toList();

      // Actualizar la tarea para asignar usuarios
      await _firestore.collection('tasks').doc(task.id).update({
        'assignedUsers': FieldValue.arrayUnion(userRefs),
      });

      // Actualizar cada usuario para registrar la tarea asignada
      for (DocumentReference userRef in userRefs) {
        await userRef.update({
          'assignedTasks': FieldValue.arrayUnion(
              [_firestore.collection('tasks').doc(task.id)]),
        });
      }

      return FirestoreResult(
          true, 'Usuarios asignados exitosamente a la tarea');
    } catch (e) {
      return FirestoreResult(false, 'Error asignando usuarios a la tarea: $e');
    }
  }

  // getTaskByUser es una función que obtiene las tareas asignadas a un usuario

  Future<List<Task>> getTasksByUser(String userId) async {
    try {
      // Obtener el documento del usuario
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return []; // El usuario no existe
      }

      // Obtener las referencias de tareas asignadas al usuario
      List<DocumentReference> taskRefs =
          List<DocumentReference>.from(userDoc['assignedTasks']);

      // Obtener las tareas a partir de las referencias de documentos
      List<Task> tasks = [];
      for (DocumentReference taskRef in taskRefs) {
        DocumentSnapshot taskDoc = await taskRef.get();
        if (taskDoc.exists) {
          Task task = Task.fromDocument(taskDoc);
          tasks.add(task);
        }
      }

      return tasks;
    } catch (e) {
      throw Exception('Error obteniendo tareas asignadas al usuario: $e');
    }
  }

  // Función que muestra las tareas que están en estado 'busy'
  // lo hará por page de 20 tareas para no saturar la aplicación
  Future<List<Task>> getBusyTasks({int limit = 20}) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('tasks')
          .where('status', isEqualTo: 'busy')
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Error obteniendo tareas ocupadas: $e');
    }
  }

  // Función que agrega una tarea a la colección 'tasks'
  Future<void> addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add(task.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<FirestoreResult> createUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      });

      return FirestoreResult(true, 'Usuario creado exitosamente');
    } catch (e) {
      return FirestoreResult(false, 'Error creando el usuario: $e');
    }
  }

  Future<FirestoreResult> updateDisplayName(
      String userId, String displayName) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'displayName': displayName,
      });

      return FirestoreResult(
          true, 'Nombre de usuario actualizado exitosamente');
    } catch (e) {
      return FirestoreResult(
          false, 'Error actualizando el nombre de usuario: $e');
    }
  }

  Future<FirestoreResult> updatePhotoURL(String userId, String photoURL) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'photoURL': photoURL,
      });

      return FirestoreResult(true, 'Foto de perfil actualizada exitosamente');
    } catch (e) {
      return FirestoreResult(false, 'Error actualizando la foto de perfil: $e');
    }
  }

  Future<FirestoreResult> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      });

      return FirestoreResult(true, 'Usuario actualizado exitosamente');
    } catch (e) {
      return FirestoreResult(false, 'Error actualizando el usuario: $e');
    }
  }

  Future<User?> getUser(String userId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return User.fromDocument(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
