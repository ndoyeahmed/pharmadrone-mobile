class RegionModel {
  final int id;
  final String nom;

  RegionModel({this.id, this.nom});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(id: json['id'], nom: json['nom']);
  }
}
