import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:pharmadrone/widgets/menu_drawer.dart';

class PharmacyScreen extends StatefulWidget {
  @override
  _PharmacyScreenState createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> _locations = ['Dakar', 'Thiès', 'Diourbel', 'Matam']; // Option 2
  String _selectedLocation; // Option 2

  GoogleMapController mapController;
  Position position;
  Set<Marker> _markers = HashSet<Marker>();
  CameraPosition _cameraPosition;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getMyPosition() async {
    position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('locationtest'),
          position: LatLng(position.latitude, position.longitude)));
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 16.0);
    });
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

  Widget getTextFormField(String labelText, TextInputType textInputType) {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Veuillez renseigner ce champs';
        }
        return null;
      },
      decoration: InputDecoration(labelText: labelText),
      keyboardType: textInputType,
    );
  }

  Widget getForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          getTextFormField('Nom de la pharmacie', TextInputType.text),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          getTextFormField('Téléphone de la pharmacie', TextInputType.phone),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          DropdownButton(
            isExpanded: true,
            hint: Text('Sélectionnez votre région'),
            value: _selectedLocation,
            onChanged: (newValue) {
              setState(() {
                _selectedLocation = newValue;
              });
            },
            items: _locations.map((location) {
              return DropdownMenuItem(
                child: Text(location),
                value: location,
              );
            }).toList(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          RaisedButton(
              child: Text('Tap pour obtenir votre position'),
              onPressed: getMyPosition,
              color: Colors.green[800],
              hoverColor: Colors.grey[300],
              textColor: Colors.white),
          Container(
            child: SizedBox(
              height: 250.0,
              child:
                  _cameraPosition == null ? getLoaderWidget() : getMapsWidget(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0),
          ),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              color: Colors.blue[500],
              hoverColor: Colors.grey[300],
              textColor: Colors.white,
              onPressed: () {
                if (_selectedLocation == null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('La région est obligatoire'),
                  ));
                } else if (position == null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Vos coordonnées géographique sont obligatoires'),
                  ));
                } else if (!_formKey.currentState.validate()) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Nom et téléphone pharmacie obligatoire'),
                  ));
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Processing data'),
                  ));
                }
              },
              child: Text('Enregistrer'),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('Ajouter ma pharmacie'),
          ),
          backgroundColor: Colors.green[700],
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(child: Icon(Icons.more_vert)),
            )
          ],
        ),
        drawer: MenuDrawerWidget(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Builder(
              builder: (context) => getForm(context),
            ),
          ),
        ));
  }
}
