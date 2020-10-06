import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:pharmadrone/models/pharmacie-model.dart';
import 'package:pharmadrone/models/region-model.dart';
import 'package:pharmadrone/widgets/menu_drawer.dart';
import 'package:pharmadrone/services/pharmacie-service.dart'
    as pharmacieService;

class PharmacyScreen extends StatefulWidget {
  @override
  _PharmacyScreenState createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final _formKey = GlobalKey<FormState>();
  List<RegionModel> _regions = []; // Option 2
  RegionModel _selectedRegion; // Option 2
  Future<List<RegionModel>> futureRegions;
  PharmacieModel pharmacieModel;

  GoogleMapController mapController;
  Position position;
  Set<Marker> _markers = HashSet<Marker>();
  CameraPosition _cameraPosition;

  final nomPharmacieController = TextEditingController();
  final telephonePharmacieController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureRegions = getListRegion();
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
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 16.0);
    });
  }

  Future<void> createPharmacy() async {
    final response = await pharmacieService.createPharmacy(pharmacieModel);
    if (response.statusCode == 201) {
      print('saved!');
    } else {
      print('not saved');
    }
  }

  Future<List<RegionModel>> getListRegion() async {
    final response = await pharmacieService.fetchRegions();
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print(decoded);
      return (decoded as List).map((e) => RegionModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load regions');
    }
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

  Widget getTextFormField(String labelText, TextInputType textInputType,
      TextEditingController controller) {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Veuillez renseigner ce champs';
        }
        return null;
      },
      decoration: InputDecoration(labelText: labelText),
      keyboardType: textInputType,
      controller: controller,
    );
  }

  Widget getForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          getTextFormField('Nom de la pharmacie', TextInputType.text,
              nomPharmacieController),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          getTextFormField('Téléphone de la pharmacie', TextInputType.phone,
              telephonePharmacieController),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          FutureBuilder(
            future: futureRegions,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _regions = snapshot.data;
                return DropdownButton(
                  isExpanded: true,
                  hint: Text('Sélectionnez votre région'),
                  value: _selectedRegion,
                  onChanged: (newValue) {
                    print(newValue);
                    setState(() {
                      _selectedRegion = newValue;
                    });
                  },
                  items: _regions.map((region) {
                    return DropdownMenuItem(
                      child: Text(region.nom),
                      value: region,
                    );
                  }).toList(),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return getLoaderWidget();
            },
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
                if (_selectedRegion == null) {
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
                  pharmacieModel = PharmacieModel(
                      latitude: position.latitude,
                      longitude: position.longitude,
                      nom: nomPharmacieController.text,
                      telephone: telephonePharmacieController.text,
                      region: _selectedRegion);

                  createPharmacy();
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
