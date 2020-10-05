import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:pharmadrone/widgets/menu_drawer.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  Position position;
  Set<Marker> _markers = HashSet<Marker>();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  CameraPosition _cameraPosition;

  @override
  void initState() {
    super.initState();
    getMyPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getMyPosition() async {
    position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('locationtest'),
          position: LatLng(position.latitude, position.longitude)));
    });

    setState(() {
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 16.0);
    });
  }

  Widget getSearchBoxWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            cursorColor: Colors.black,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: "Mettez le nom du médicament...."),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            child: Icon(Icons.search),
            onTap: () {
              scaffoldKey.currentState
                  .showBottomSheet((context) => BottomSheetWidget());
            },
          ),
        )
      ],
    );
  }

  Widget getDrawerWidget(BuildContext context) {
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

  Widget getMapsWidget() {
    return GoogleMap(
      mapType: MapType.hybrid,
      markers: _markers,
      onMapCreated: _onMapCreated,
      initialCameraPosition: _cameraPosition,
    );
  }

  Widget getLoaderWidget() {
    return Container(
        child: Center(
      child: LoadingBouncingGrid.square(
        size: 80.0,
        backgroundColor: Colors.green,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text('Accueil'),
        ),
        backgroundColor: Colors.green[700],
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(child: Icon(Icons.more_vert)),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          // test camera position value and add a loader animation if null else load map
          _cameraPosition == null ? getLoaderWidget() : getMapsWidget(),
          Positioned(
            // search input position
            top: 10,
            right: 15,
            left: 15,
            child: Container(
              // search input container
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  )),
              child: getSearchBoxWidget(), // add the search input row
            ),
          )
        ],
      ),
      drawer: MenuDrawerWidget(), // add the menu page
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text('Pharmacie GUIGON'),
            subtitle: Text('Médicament disponible'),
          ),
          ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text('Pharmacie GUIGON'),
            subtitle: Text('Médicament disponible'),
          ),
          ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text('Pharmacie GUIGON'),
            subtitle: Text('Médicament disponible'),
          ),
          ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text('Pharmacie GUIGON'),
            subtitle: Text('Médicament disponible'),
          ),
        ],
      ),
    );
  }
}
