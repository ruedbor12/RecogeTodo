
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:rodrigo_moraga_proyecto/pages/mis_publicaciones.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rodrigo_moraga_proyecto/services/fs_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rodrigo_moraga_proyecto/utils/fecha_format.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final buscarCtrl = TextEditingController();
  final fs = FsService();  

  String textoBusqueda = '';

  @override
  void dispose() {
    buscarCtrl.dispose();
    super.dispose();
  }
  // Función para mostrar el detalle de la publicación en un cuadro de diálogo.
  void mostrarDetalle(Map<String, dynamic> publicacion) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          
          title: Text('Detalle de publicación'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (publicacion['foto'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      (publicacion['foto'] as Blob).bytes,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),

                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tipo: ${publicacion['tipo']} - ${publicacion['categoria']}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Estado: ${publicacion['estado']}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    
                  ],
                ),                

                SizedBox(height: 4),

                Text(
                  'Lugar: ${publicacion['lugar']}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                ),

                SizedBox(height: 4), 

                Text(
                  'Publicado por: ${publicacion['nombreUsuario'] ?? 'Usuario'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),

                SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nota de contacto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    (publicacion['notaContacto'] ?? '').toString().isNotEmpty
                        ? publicacion['notaContacto']
                        : 'El usuario no agregó una nota de contacto.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
  // builder principal de la página de inicio, donde se muestran las publicaciones y el buscador.
  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              MdiIcons.excavator,
              color: Colors.black,
              size: 30,
            ),
            SizedBox(width: 2),
            Text(
              'Recogetodo',
              style: TextStyle(
                color:  Color.fromARGB(255, 3, 129, 77),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF5A623),
                Color(0xFF292929),
              ],
              stops: [0.65, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage: usuario?.photoURL != null
                      ? NetworkImage(usuario!.photoURL!)
                      : null,
                  child: usuario?.photoURL == null
                      ? Icon(
                          MdiIcons.accountCircleOutline,
                          color: Colors.black,
                        )
                      : null,
                ),
                SizedBox(width: 4),


                SizedBox(
                  width: 85,
                  child: Text(
                    usuario?.displayName ?? 'Usuario',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),

                SizedBox(width: 5),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),

            onSelected: (value) async {
              if (value == 'cerrar') {
                await FirebaseAuth.instance.signOut();
              }
            },

            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'cerrar',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/amarillo.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.35),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [

                      // Buscador
                      TextField(
                        controller: buscarCtrl,
                        onChanged: (value) {
                          setState(() {
                            textoBusqueda = value.toLowerCase().trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar objetos...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: IconButton(
                            onPressed: () {
                              buscarCtrl.clear();
                              setState(() {
                                textoBusqueda = '';
                              });
                            },
                            icon: Icon(Icons.close),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // Listado de publicaciones
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: fs.publicaciones(),
                          builder: (context, snapshot) {

                            if(snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            // documentos tomados desde la Firestore.
                            final documentos = snapshot.data!.docs.where((doc) {
                              final publicacion = doc.data() as Map<String, dynamic>;

                              final titulo = (publicacion['titulo'] ?? '').toString().toLowerCase();
                              final descripcion = (publicacion['descripcion'] ?? '').toString().toLowerCase();
                              final categoria = (publicacion['categoria'] ?? '').toString().toLowerCase();
                              final lugar = (publicacion['lugar'] ?? '').toString().toLowerCase();
                              final tipo = (publicacion['tipo'] ?? '').toString().toLowerCase();

                              return titulo.contains(textoBusqueda) ||
                                  descripcion.contains(textoBusqueda) ||
                                  categoria.contains(textoBusqueda) ||
                                  lugar.contains(textoBusqueda) ||
                                  tipo.contains(textoBusqueda);
                            }).toList();

                            return ListView.builder(
                              itemCount: documentos.length,
                              itemBuilder: (context, index) {

                                final publicacion =
                                    documentos[index].data()
                                        as Map<String, dynamic>;

                                final fecha = (publicacion['fechaHora'] as Timestamp).toDate();

                                // inciio de los Card de las publicaciones, con la información de la base de datos.
                                return InkWell(
                                  onTap: () {

                                    
                                    mostrarDetalle(publicacion);
                                  },


                                  child: Card(
                                    margin: EdgeInsets.only(bottom: 15),
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Fotografía
                                        
                                      Container(
                                        height: 170,
                                        width: double.infinity,
                                        color: Color(0xFFE8E5DC),
                                        child: publicacion['foto'] != null
                                            ? Image.memory(
                                                (publicacion['foto'] as Blob).bytes,
                                                width: double.infinity,
                                                height: 170,
                                                fit: BoxFit.cover,
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    MdiIcons.imageOutline,
                                                    size: 45,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Fotografía del objeto',
                                                    style: TextStyle(color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                      ),
                                  
                                  
                                        // Información
                                        Padding(
                                          padding: EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // row de titulo y estado
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      publicacion['titulo'],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    publicacion['estado'],
                                                    style: TextStyle(
                                                      color: publicacion['estado'] == 'Devuelto'
                                                          ? Colors.green
                                                          : Colors.orange,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                  
                                              SizedBox(height: 5),
                                  
                                              Row(
                                                children: [
                                                  Icon(
                                                    MdiIcons.accountOutline,
                                                    size: 16,
                                                    color: Colors.grey[700],
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    'Publicado por: ${publicacion['nombreUsuario'] ?? 'Usuario'}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                  
                                              SizedBox(height: 12),
                                  
                                              // row de categoria, lugar y fecha
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(MdiIcons.tagOutline, size: 17),
                                                      SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(publicacion['categoria']),
                                                      ),
                                                    ],
                                                  ),
                                  
                                                  Row(
                                                    children: [
                                                      Icon(MdiIcons.mapMarkerOutline, size: 17),
                                                      SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(publicacion['lugar']),
                                                      ),
                                                    ],
                                                  ),
                                  
                                                  Row(
                                                    children: [
                                                      Icon(MdiIcons.clockOutline, size: 15),
                                                      SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          '${formatearFecha(fecha)} · ${formatearHora(fecha)}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                  
                                              SizedBox(height: 10),
                                  
                                              // detalle de la descripcion
                                              Text(
                                                publicacion['descripcion'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                  
                                              SizedBox(height: 12),
                                  
                                              //tipo de publicacion
                                              Text(
                                                publicacion['tipo'],
                                                style: TextStyle(
                                                  color: publicacion['tipo'] == 'Perdido'
                                                      ? Colors.red
                                                      : publicacion['tipo'] == 'Encontrado'
                                                          ? Colors.blue
                                                          : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(12, 5, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MisPublicaciones(),
                        ),
                      );
                    },
                    icon: Icon(MdiIcons.accountBoxOutline),
                    label: Text('Mis publicaciones'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF292929),
                      foregroundColor: Color(0xFFFFD43B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
