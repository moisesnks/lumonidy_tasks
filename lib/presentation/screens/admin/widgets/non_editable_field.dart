import 'package:flutter/material.dart';

class NonEditableField extends StatelessWidget {
  final String fieldLabel;
  final String fieldValue;

  const NonEditableField({
    super.key,
    required this.fieldLabel,
    required this.fieldValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey), // Define un borde alrededor del campo
        borderRadius: BorderRadius.circular(4.0), // Define esquinas redondeadas
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fieldLabel,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0), // Espacio entre etiqueta y valor
              Text(
                fieldValue,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
