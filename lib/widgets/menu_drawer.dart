import 'package:flutter/material.dart';

class MenuDrawerWidget extends StatefulWidget {
  @override
  _MenuDrawerWidgetState createState() => _MenuDrawerWidgetState();
}

class _MenuDrawerWidgetState extends State<MenuDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Center(
              child: CircleAvatar(
                radius: 70.0,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                    'https://png.pngtree.com/element_our/png_detail/20180912/health-logo-template-png_91808.jpg'),
              ),
            ),
            decoration: BoxDecoration(color: Colors.green[700]),
          ),
          ListTile(
            title: Text('Accueil'),
            leading: Icon(Icons.home),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            title: Text('Ajouter ma pharmacie'),
            leading: Icon(Icons.add),
            onTap: () {
              Navigator.pushNamed(context, 'pharmacy-add');
            },
          )
        ],
      ),
    );
  }
}
