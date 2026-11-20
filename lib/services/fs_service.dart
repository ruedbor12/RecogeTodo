import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class FsService {

  // Obtener publicaciones
  Stream<QuerySnapshot> publicaciones() {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .snapshots();
  }

  // Obtener publicaciones del usuario
  Stream<QuerySnapshot> publicacionesUsuario(String usuarioId) {
    return FirebaseFirestore.instance.collection('publicaciones').where('usuarioId', isEqualTo: usuarioId).snapshots();
  }
  // Obtener categorías
  Stream<QuerySnapshot> categorias() {
    return FirebaseFirestore.instance.collection('categorias').orderBy('nombre').snapshots();
  }

  // Agregar publicación
  Future<void> agregarPublicacion({

    required String titulo,
    required String descripcion,
    required String tipo,
    required String categoria,
    required String lugar,
    required DateTime fechaHora,
    required String usuarioId,
    required String nombreUsuario,
    required String notaContacto,
    Uint8List? foto,

  }) {

    final datos = {
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'estado': 'Vigente',
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'notaContacto': notaContacto,
    };

    if (foto != null) {
      datos['foto'] = Blob(foto);
    }

    return FirebaseFirestore.instance.collection('publicaciones').doc().set(datos);
  }


  // Editar publicación

  Future<void> editarPublicacion({

    required String publicacionId,
    required String titulo,
    required String descripcion,
    required String tipo,
    required String categoria,
    required String lugar,
    required DateTime fechaHora,
    required String estado,
    Uint8List? foto,

  }) {

    final datos = {
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'estado': estado,
    };

    if (foto != null) {
      datos['foto'] = Blob(foto);
    }

    return FirebaseFirestore.instance.collection('publicaciones').doc(publicacionId).update(datos);
  }


  // Borrar publicación
  Future<void> eliminarPublicacion(String publicacionId) {
    return FirebaseFirestore.instance.collection('publicaciones').doc(publicacionId).delete();
  }
}