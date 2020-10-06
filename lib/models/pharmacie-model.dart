import 'package:pharmadrone/models/region-model.dart';

class PharmacieModel {
  final int id;
  final String nom;
  final String telephone;
  final double latitude;
  final double longitude;
  final RegionModel region;

  PharmacieModel(
      {this.id,
      this.latitude,
      this.longitude,
      this.nom,
      this.telephone,
      this.region});
}
