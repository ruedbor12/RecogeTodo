import 'package:intl/intl.dart';

String formatearFecha(DateTime fecha) {
  return DateFormat('dd/MM/yyyy').format(fecha);
}

String formatearHora(DateTime fecha) {
  return DateFormat('HH:mm').format(fecha);
}