import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contactos en flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Contactos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> contactos = [];
  List<Contact> contactosFiltrados = [];
  TextEditingController controlador = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPermissions();
    controlador.addListener(() {
      filtroContactos();
    });
  }

  String strNumero(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  filtroContactos() {
    List<Contact> _contactos = [];
    _contactos.addAll(contactos);

    if (controlador.text.isNotEmpty) {
      //retainwhere hace que si se cumple la condicion se borra
      _contactos.retainWhere((contact) {
        String strBusqueda = controlador.text.toLowerCase();
        String strNumBuscado = strNumero(strBusqueda);
        String? nombreContacto = contact.displayName;
        String? telContacto = contact.phones!.elementAt(0).value;
        bool nombresIg = nombreContacto!.toLowerCase().contains(strBusqueda);
        bool telIg = telContacto!.contains(strNumBuscado);

        if (nombresIg == true) {
          return true;
        }
        if (telIg) {
          return true;
        } else {
          return false;
        }
      });
      setState(() {
        contactosFiltrados = _contactos;
      });
    }
  }

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
    }
  }

  getAllContacts() async {
    List<Contact> _contactos =
        (await ContactsService.getContacts(withThumbnails: false)).toList();
    setState(() {
      contactos = _contactos;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool filtrado = controlador.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const Text('Contactos'),
            Container(
              child: TextField(
                controller: controlador,
                decoration: InputDecoration(
                  labelText: 'Buscar',
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor)),
                  prefixIcon:
                      Icon(Icons.search, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtrado == true
                        ? contactosFiltrados.length
                        : contactos.length,
                    itemBuilder: (context, index) {
                      Contact contactoAux = filtrado == true
                          ? contactosFiltrados[index]
                          : contactos[index];

                      String? nombre = contactoAux.displayName;
                      String? iniciales = contactoAux.initials();

                      String? numero = contactoAux.phones!.elementAt(0).value;
                      return ListTile(
                          title: Text(nombre!),
                          subtitle: Text(numero!),
                          leading: CircleAvatar(
                            child: Text(iniciales),
                          ));
                    }))
          ],
        ),
      ),
    );
  }
}
