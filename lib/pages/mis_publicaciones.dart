import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rodrigo_moraga_proyecto/services/fs_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rodrigo_moraga_proyecto/utils/fecha_format.dart';



class MisPublicaciones extends StatefulWidget {
  const MisPublicaciones({super.key});

  @override
  State<MisPublicaciones> createState() => _MisPublicacionesState();
}

class _MisPublicacionesState extends State<MisPublicaciones> {

  final fs = FsService();

  final formAgregarKey = GlobalKey<FormState>();

  final tituloCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();
  final notaContactoCtrl = TextEditingController();

  String? tipoSeleccionado;
  String? categoriaSeleccionada;
  String? estadoSeleccionado;

  bool guardando = false;
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  final ImagePicker picker = ImagePicker();

  XFile? imagenSeleccionada;
  Uint8List? imagenComprimida;

  // Función para limpiar el formulario

  void limpiarForm() {
    tituloCtrl.clear();
    descripcionCtrl.clear();
    lugarCtrl.clear();

    tipoSeleccionado = null;
    categoriaSeleccionada = null;

    fechaSeleccionada = null;
    horaSeleccionada = null;

    imagenSeleccionada = null;
    imagenComprimida = null;

    estadoSeleccionado = null;
    notaContactoCtrl.clear();

    guardando = false;

    formAgregarKey.currentState?.reset();



    setState(() {});
  }

  
  // Función para mostrar el diálogo de agregar publicación
  void mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, actualizarDialogo){
            return AlertDialog(
            title: Text(
              'Nueva publicación',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292929),
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
          
              child: SingleChildScrollView(
                child: Form(
                  key: formAgregarKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título del objeto
                      TextFormField(
                        controller: tituloCtrl,
                        decoration: InputDecoration(
                          labelText: 'Objeto',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese el título del objeto';
                          }
                          return null;
                        },
                      ),
                
                      // Descripción
                      TextFormField(
                        controller: descripcionCtrl,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese una descripción';
                          }
                          return null;
                        },
                      ),

                      // Nota de contacto
                      TextFormField(
                        controller: notaContactoCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nota de contacto (opcional)',
                          hintText: 'Ej: Puedes contactarme al correo...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                
                      // Lugar
                      TextFormField(
                        controller: lugarCtrl,
                        decoration: InputDecoration(
                          labelText: 'Lugar',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Indique dónde se perdió o encontró';
                          }
                          return null;
                        },
                      ),
                
                      // Categoría
                      StreamBuilder<QuerySnapshot>(
                        stream: fs.categorias(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error al cargar categorías');
                          }

                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          final categoriasFirestore = snapshot.data!.docs;

                          return DropdownButtonFormField<String>(
                            value: categoriaSeleccionada,
                            decoration: InputDecoration(
                              labelText: 'Categoría',
                            ),
                            items: categoriasFirestore.map((documento) {
                              final categoria = documento['nombre'] as String;

                              return DropdownMenuItem<String>(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                categoriaSeleccionada = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Seleccione una categoría';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                
                      DropdownButtonFormField<String>(
                        value: tipoSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Tipo',
                        ),
                        items: ['Perdido', 'Encontrado'].map((tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            tipoSeleccionado = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Seleccione un tipo';
                          }
                          return null;
                        },
                      ),
                
                      ListTile(
                        title: Text(
                          fechaSeleccionada == null
                              ? 'Seleccionar fecha'
                              : '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}',
                        ),
                        leading: Icon(Icons.calendar_month),
                        trailing: Icon(Icons.edit_calendar),
                        onTap: seleccionarFecha,
                      ),
                
                      ListTile(
                        title: Text(
                          horaSeleccionada == null
                              ? 'Seleccionar hora'
                              : horaSeleccionada!.format(context),
                        ),
                        leading: Icon(Icons.access_time),
                        trailing: Icon(Icons.edit),
                        onTap: seleccionarHora,
                      ),
                
                      // Fotografía del objeto
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fotografía del objeto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                
                          SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.orange[800],
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'La imagen no debe superar los 850 KB.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),
                
                          if (imagenSeleccionada != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                imagenComprimida!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.image_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                
                          SizedBox(height: 10),

                          if (imagenComprimida != null)
                            Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                'Peso de la imagen: ${(imagenComprimida!.lengthInBytes / 1024).toStringAsFixed(2)} KB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),

                          SizedBox(height: 10),
                
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    seleccionarImagen(
                                      ImageSource.camera,
                                      actualizarDialogo,
                                    );
                                  },
                                  icon: Icon(Icons.camera_alt),
                                  label: Text('Cámara'),
                                ),
                              ),
                
                              SizedBox(width: 10),
                
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    seleccionarImagen(
                                      ImageSource.gallery,
                                      actualizarDialogo,
                                    );
                                  },
                                  icon: Icon(Icons.photo_library),
                                  label: Text('Galería'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                
                
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {

                  Navigator.pop(dialogContext);
                },
                child: Text('Cancelar'),
              ),

              FilledButton(
                onPressed: guardando
                    ? null
                    : () async {

                        //validar campos obligatorios
                        if (!formAgregarKey.currentState!.validate()) {
                          return;
                        }

                        // Comprobar si se seleccionó una fotografía.
                        if (imagenComprimida == null) {
                          showDialog(
                            context: dialogContext,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Fotografía requerida'),
                                content: Text('Debe seleccionar una fotografía.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Entendido'),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }

                        // Verificar el peso de la fotografía.
                        if (imagenComprimida!.lengthInBytes > 850 * 1024) {
                          showDialog(
                            context: dialogContext,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Imagen demasiado pesada'),
                                content: Text(
                                  'La fotografía supera el peso permitido. Seleccione otra imagen.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Entendido'),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }

                        // Comprobar si se seleccionó fecha.
                        if (fechaSeleccionada == null) {
                          showDialog(
                            context: dialogContext,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Fecha requerida'),
                                content: Text('Seleccione una fecha.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Entendido'),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }

                        // Comprobar si se seleccionó hora.
                        if (horaSeleccionada == null) {
                          showDialog(
                            context: dialogContext,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Hora requerida'),
                                content: Text('Seleccione una hora.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Entendido'),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }

                        final usuario = FirebaseAuth.instance.currentUser;

                        // Comprobar si hay un usuario autenticado.
                        if (usuario == null) {
                          showDialog(
                            context: dialogContext,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Sesión no encontrada'),
                                content: Text('No hay un usuario autenticado.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Entendido'),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }

                        actualizarDialogo(() {
                          guardando = true;
                        });

                        try {
                          final fechaHora = DateTime(
                            fechaSeleccionada!.year,
                            fechaSeleccionada!.month,
                            fechaSeleccionada!.day,
                            horaSeleccionada!.hour,
                            horaSeleccionada!.minute,
                          );

                          await fs.agregarPublicacion(
                            titulo: tituloCtrl.text.trim(),
                            descripcion: descripcionCtrl.text.trim(),
                            tipo: tipoSeleccionado!,
                            categoria: categoriaSeleccionada!,
                            lugar: lugarCtrl.text.trim(),
                            fechaHora: fechaHora,
                            usuarioId: usuario.uid,
                            nombreUsuario: usuario.displayName ?? 'Usuario',
                            foto: imagenComprimida,
                            notaContacto: notaContactoCtrl.text.trim(),
                          );

                          if (!mounted) return;

                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('¡Publicación agregada correctamente!'),
                            ),
                          );
                        } catch (e) {
                          actualizarDialogo(() {
                            guardando = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al publicar: $e'),
                            ),
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0xFFF5A623),
                  foregroundColor: Color(0xFF292929),
                ),
                child: Text(guardando ? 'Publicando...' : 'Publicar'),
              ),

             ],
            );  
          },
          
        );
      },
    ).then((_) => limpiarForm());
  }    
 
  
  void mostrarDialogoEditar(
    String publicacionId,
    Map<String, dynamic> publicacion,
  ) {
    // Cargar datos actuales
    tituloCtrl.text = publicacion['titulo'];
    descripcionCtrl.text = publicacion['descripcion'];
    lugarCtrl.text = publicacion['lugar'];

    tipoSeleccionado = publicacion['tipo'];
    categoriaSeleccionada = publicacion['categoria'];
    estadoSeleccionado = publicacion['estado'];

    // Recuperar fecha y hora
    final fecha = (publicacion['fechaHora'] as Timestamp).toDate();

    fechaSeleccionada = fecha;
    horaSeleccionada = TimeOfDay(
      hour: fecha.hour,
      minute: fecha.minute,
    );

    // Recuperar fotografía existente
    final Blob? foto = publicacion['foto'] as Blob?;

    imagenComprimida = foto?.bytes;
    imagenSeleccionada = null;

    guardando = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, actualizarDialogo) {
            return AlertDialog(
              title: Text(
                'Editar publicación',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292929),
                ),
              ),

              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formAgregarKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        TextFormField(
                          controller: tituloCtrl,
                          decoration: InputDecoration(
                            labelText: 'Objeto',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese el título del objeto';
                            }
                            return null;
                          },
                        ),

                        TextFormField(
                          controller: descripcionCtrl,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese una descripción';
                            }
                            return null;
                          },
                        ),

                        TextFormField(
                          controller: lugarCtrl,
                          decoration: InputDecoration(
                            labelText: 'Lugar',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Indique dónde se perdió o encontró';
                            }
                            return null;
                          },
                        ),

                        StreamBuilder<QuerySnapshot>(
                          stream: fs.categorias(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error al cargar categorías');
                            }

                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }

                            final categoriasFirestore = snapshot.data!.docs;

                            return DropdownButtonFormField<String>(
                              value: categoriaSeleccionada,
                              decoration: InputDecoration(
                                labelText: 'Categoría',
                              ),
                              items: categoriasFirestore.map((documento) {
                                final categoria = documento['nombre'] as String;

                                return DropdownMenuItem<String>(
                                  value: categoria,
                                  child: Text(categoria),
                                );
                              }).toList(),
                              onChanged: (value) {
                                actualizarDialogo(() {
                                  categoriaSeleccionada = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Seleccione una categoría';
                                }
                                return null;
                              },
                            );
                          },
                        ),

                        // Tipo de publicación
                        DropdownButtonFormField<String>(
                          value: tipoSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Tipo',
                          ),
                          items: ['Perdido', 'Encontrado'].map((tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                          onChanged: (value) {
                            actualizarDialogo(() {
                              tipoSeleccionado = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Seleccione un tipo';
                            }
                            return null;
                          },
                        ),

                        // Estado de la publicación
                        DropdownButtonFormField<String>(
                          value: estadoSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Estado',
                          ),
                          items: ['Vigente', 'Devuelto'].map((estado) {
                            return DropdownMenuItem<String>(
                              value: estado,
                              child: Text(estado),
                            );
                          }).toList(),
                          onChanged: (value) {
                            actualizarDialogo(() {
                              estadoSeleccionado = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Seleccione un estado';
                            }
                            return null;
                          },
                        ),

                        ListTile(
                          title: Text(
                            fechaSeleccionada == null
                                ? 'Seleccionar fecha'
                                : '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}',
                          ),
                          leading: Icon(Icons.calendar_month),
                          trailing: Icon(Icons.edit_calendar),
                          onTap: () => seleccionarFecha(),
                        ),

                        ListTile(
                          title: Text(
                            horaSeleccionada == null
                                ? 'Seleccionar hora'
                                : horaSeleccionada!.format(context),
                          ),
                          leading: Icon(Icons.access_time),
                          trailing: Icon(Icons.edit),
                          onTap: () => seleccionarHora(),
                        ),

                        // Fotografía existente o nueva
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fotografía del objeto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 10),

                            if (imagenComprimida != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  imagenComprimida!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),

                            SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      seleccionarImagen(
                                        ImageSource.camera,
                                        actualizarDialogo,
                                      );
                                    },
                                    icon: Icon(Icons.camera_alt),
                                    label: Text('Cámara'),
                                  ),
                                ),

                                SizedBox(width: 10),

                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      seleccionarImagen(
                                        ImageSource.gallery,
                                        actualizarDialogo,
                                      );
                                    },
                                    icon: Icon(Icons.photo_library),
                                    label: Text('Galería'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text('Cancelar'),
                ),

                FilledButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formAgregarKey.currentState!.validate()) {
                            return;
                          }

                          if (fechaSeleccionada == null ||
                              horaSeleccionada == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Seleccione fecha y hora'),
                              ),
                            );
                            return;
                          }

                          actualizarDialogo(() {
                            guardando = true;
                          });

                          try {
                            final fechaHora = DateTime(
                              fechaSeleccionada!.year,
                              fechaSeleccionada!.month,
                              fechaSeleccionada!.day,
                              horaSeleccionada!.hour,
                              horaSeleccionada!.minute,
                            );

                            await fs.editarPublicacion(
                              publicacionId: publicacionId,
                              titulo: tituloCtrl.text.trim(),
                              descripcion: descripcionCtrl.text.trim(),
                              tipo: tipoSeleccionado!,
                              categoria: categoriaSeleccionada!,
                              lugar: lugarCtrl.text.trim(),
                              fechaHora: fechaHora,
                              foto: imagenComprimida,
                              estado: estadoSeleccionado!,
                            );

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '¡Publicación actualizada correctamente!',
                                ),
                              ),
                            );
                          } catch (e) {
                            actualizarDialogo(() {
                              guardando = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al editar: $e'),
                              ),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xFFF5A623),
                    foregroundColor: Color(0xFF292929),
                  ),
                  child: Text(
                    guardando ? 'Guardando...' : 'Guardar cambios',
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => limpiarForm());
  }

  

  //funcion para seleccionar fecha.
  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (fecha != null) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }
  
  //funcion para seleccionar hora.
  Future<void> seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        horaSeleccionada = hora;
      });
    }
  }

  //funcion seleccionar imagen.
  Future<void> seleccionarImagen(
    ImageSource origen,
    StateSetter actualizarDialogo,
  ) async {
    final imagen = await picker.pickImage(source: origen);

    if (imagen != null) {
      final bytes = await comprimirImagen(imagen);

      if (bytes != null) {
        actualizarDialogo(() {
          imagenSeleccionada = imagen;
          imagenComprimida = bytes;
        });
      }
    }
  }

  //funcion para comprimir imagen, y posteriormente mandarla al bd.
  Future<Uint8List?> comprimirImagen(XFile imagen) async {
    final dimensiones = await decodeImageFromList(
      await imagen.readAsBytes(),
    );

    int ancho = dimensiones.width;
    int alto = dimensiones.height;

    // Reducir si el lado mayor supera los 1024 px.
    if (ancho > 1024 || alto > 1024) {
      double escala = 1024 / (ancho > alto ? ancho : alto);

      ancho = (ancho * escala).round();
      alto = (alto * escala).round();
    }

    final resultado = await FlutterImageCompress.compressWithFile(
      imagen.path,
      minWidth: ancho,
      minHeight: alto,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    return resultado;
  }

  Future<void> confirmarEliminar(String publicacionId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar publicación'),
        content: Text('¿Estás seguro de que deseas eliminar esta publicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await fs.eliminarPublicacion(publicacionId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Publicación eliminada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la publicación')),
      );
    }
  }
  
  
  
  @override
    void dispose() {
      tituloCtrl.dispose();
      descripcionCtrl.dispose();
      lugarCtrl.dispose();

      super.dispose();
  }




  // aqui yacen los datos temporales,
    //cuyo caso sirvieron para los primeros modelos sin FireStore. :c
  // end seccion de datos temporales.


  // Determinar rango
  String rangoUsuario(int cantidad) {
    if (cantidad >= 8) return 'Recolector Supremo';
    if (cantidad >= 6) return 'Recolector Experto';
    if (cantidad >= 4) return 'Recolector Maestro';
    if (cantidad >= 2) return 'Recolector Junior';

    return 'Recolector Novato';
  }

  // Icono del rango
  IconData iconoRango(int cantidad) {
    if (cantidad >= 8) return Icons.diamond;
    if (cantidad >= 6) return Icons.star;
    if (cantidad >= 4) return Icons.military_tech;
    if (cantidad >= 2) return Icons.monetization_on;

    return Icons.handyman;
  }

  // Color del rango
  Color colorRango(int cantidad) {
    if (cantidad >= 8) return Color(0xFF55BCEB);
    if (cantidad >= 6) return Color.fromARGB(255, 255, 21, 0);
    if (cantidad >= 4) return Color.fromARGB(255, 81, 96, 174);
    if (cantidad >= 2) return Color(0xFFB77942);

    return Color.fromARGB(255, 86, 47, 2);
  }

  // Progreso hacia el siguiente rango
  double progresoRango(int cantidad) {
    if (cantidad >= 8) return 1.0;

    int inicio = (cantidad ~/ 2) * 2;

    return (cantidad - inicio) / 2;
  }

  // Publicaciones restantes para el siguiente rango
  int publicacionesRestantes(int cantidad) {
    if (cantidad >= 8) return 0;

    int siguiente = ((cantidad ~/ 2) + 1) * 2;

    return siguiente - cantidad;
  }

  // Widget para mostrar la tarjeta del usuario y su progreso
  Widget tarjetaUsuario(int cantidad, String nombreUsuario) {
    

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFD43B),
            Color(0xFFF5A623),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [

              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage:
                    FirebaseAuth.instance.currentUser?.photoURL != null
                        ? NetworkImage(
                            FirebaseAuth.instance.currentUser!.photoURL!,
                          )
                        : null,
                child: FirebaseAuth.instance.currentUser?.photoURL == null
                    ? Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF292929),
                      )
                    : null,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreUsuario,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF292929),
                      ),
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          iconoRango(cantidad),
                          color: colorRango(cantidad),
                          size: 30,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rangoUsuario(cantidad),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF292929),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Text(
                    '$cantidad',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF292929),
                    ),
                  ),
                  Text(
                    'Publicaciones',
                    style: TextStyle(
                      fontSize: 8,
                      color: Color(0xFF292929),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso al siguiente rango',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292929),
                  fontSize: 10,
                ),
              ),
              Text(
                publicacionesRestantes(cantidad) == 0
                    ? '¡Rango máximo!'
                    : 'Faltan ${publicacionesRestantes(cantidad)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF292929),
                ),
              ),
            ],
          ),

          SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progresoRango(cantidad),
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.6),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF292929),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget Build Principal
  @override
  Widget build(BuildContext context) {

    final usuario = FirebaseAuth.instance.currentUser;



    if (usuario == null) {
      return Scaffold(
        body: Center(
          child: Text('No hay un usuario autenticado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F2),

      // AppBar con gradiente y título centrado
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 172, 107, 10),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.roadBarrier,
              color: Color(0xFFFFD43B),
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Laburando',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF292929), // Negro
                Color(0xFFF5A623), // Naranjo claro
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),

      // body qie tendra todo el contenido. tarjeta usuario, listTile.
      body: Padding(
        padding: EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot>(
          stream: fs.publicacionesUsuario(usuario.uid),
          builder: (context, snapshot) {

            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error al cargar tus publicaciones'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final documentos = snapshot.data!.docs;
            final cantidad = documentos.length;
            final nombre = usuario.displayName ?? 'Usuario';

            return Column(
              children: [
                tarjetaUsuario(cantidad, nombre),

                SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mis publicaciones',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: documentos.length,
                    itemBuilder: (context, index) {
                      final publicacion = documentos[index].data()
                          as Map<String, dynamic>;

                      final fecha = (publicacion['fechaHora'] as Timestamp).toDate();    

                      final publicacionId = documentos[index].id;    

                      return Slidable(
                        startActionPane: ActionPane(
                          motion: DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                // Editar
                                mostrarDialogoEditar(publicacionId, publicacion);
                              },
                              backgroundColor:  Color.fromARGB(46, 18, 216, 157),
                              foregroundColor:  Color.fromARGB(255, 0, 0, 0),
                              borderRadius: BorderRadius.circular(12),
                              icon: Icons.edit,
                              label: 'Editar',
                            ),
                          ],
                        ),

                        endActionPane: ActionPane(
                          motion: DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                // Eliminar
                                confirmarEliminar(publicacionId);
                              },
                              backgroundColor: Color.fromARGB(96, 139, 14, 5),
                              foregroundColor: Color.fromARGB(255, 0, 0, 0),
                              borderRadius: BorderRadius.circular(12),
                              icon: Icons.delete,
                              label: 'Eliminar',
                            ),
                          ],
                        ),


                        child: Container(
                        
                          margin: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber,
                                Color.fromARGB(189, 46, 39, 4),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(172, 0, 0, 0),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(8),
                        
                            // Imagen a la izquierda    
                          
                        
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: publicacion['foto'] != null
                                ? Image.memory(
                                    (publicacion['foto'] as Blob).bytes,
                                    width: 80,
                                    // height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Color(0xFFE8E5DC),
                                    child: Icon(
                                      MdiIcons.imageOutline,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        
                            // Título
                            title: Text(
                              publicacion['titulo'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                        
                            // Subtítulo
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Categoría y lugar
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(MdiIcons.tagOutline, size: 8, color: Colors.white),
                                          SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              publicacion['categoria'] ?? '',
                                              style: TextStyle(fontSize: 10, color: Colors.white),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      Row(
                                        children: [
                                          Icon(MdiIcons.mapMarkerOutline, size: 8, color: Colors.white),
                                          SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              publicacion['lugar'] ?? '',
                                              style: TextStyle(fontSize: 10, color: Colors.white),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                        
                                  SizedBox(height: 6),
                        
                                  // Descripción
                                  Text(
                                    publicacion['descripcion'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                        
                            // Fecha y estado
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Fecha arriba
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatearFecha(fecha),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      formatearHora(fecha),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),                                
                        
                                // Estado abajo
                                Container(
                                  
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    publicacion['estado'],
                                    style: TextStyle(
                                      color: publicacion['estado'] == 'Devuelto'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),


      // Botón flotante para agregar nueva publicación
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mostrarDialogoAgregar();
          // Aquí abriremos el diálogo para crear publicación.
        },
        backgroundColor: Color(0xFFF5A623),
        foregroundColor: Color(0xFF292929),
        child: Icon(MdiIcons.plus),
      ),

    );
  }
}