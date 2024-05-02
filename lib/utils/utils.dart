// Path: utils/print.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:intl/intl.dart';

class Utils {
  static void printLog(String message) {
    if (kDebugMode) {
      print('[LOG] $message');
    }
  }

  List<Map<String, String>> debugCredentials = [
    {
      'displayName': 'github.com/moisesnks',
      'email': 'admin@utem.cl',
      'password': 'Prueba1234',
    },
    {
      'displayName': 'Cliente',
      'email': 'cliente@gmail.com',
      'password': 'Prueba1234',
    }
  ];

  // Función util para obtener las credenciales de debug dado un index
  static Map<String, String> getDebugCredential({int index = 0}) {
    final credentials = Utils().debugCredentials;
    if (index < credentials.length) {
      return credentials[index];
    } else {
      return credentials[0];
    }
  }

  // Función útil para formatear una fecha en un formato personalizado
  static String formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime =
        timestamp.toDate(); // Convierte Timestamp a DateTime
    final localDateTime =
        dateTime.toLocal(); // Convierte a la zona horaria local

    // Define el formato deseado para la fecha y hora
    final formatter = DateFormat('d \'de\' MMMM \'de\' y, h:mm:ss a \'Z');

    // Formatea la fecha y hora según el formato definido
    final formattedDate = formatter.format(localDateTime);

    return formattedDate;
  }
}
