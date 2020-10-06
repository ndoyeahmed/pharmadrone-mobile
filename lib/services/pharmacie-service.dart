import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pharmadrone/models/pharmacie-model.dart';

Future<http.Response> fetchRegions() async {
  return http.get('https://pharmadrone-api.herokuapp.com/api/regions');
}

Future<http.Response> createPharmacy(PharmacieModel pharmacieModel) {
  return http.post(
    'https://pharmadrone-api.herokuapp.com/api/pharmacy',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'nom': pharmacieModel.nom,
      'telephone': pharmacieModel.telephone,
      'latitude': pharmacieModel.latitude.toString(),
      'longitude': pharmacieModel.longitude.toString(),
      'region': pharmacieModel.region.id.toString()
    }),
  );
}
