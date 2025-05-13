class Item {
  final int idItem;
  final int nomId;
  final int numeroItem;
  final String pregunta;
  final String seccion;

  Item({
    required this.idItem,
    required this.nomId,
    required this.numeroItem,
    required this.pregunta,
    required this.seccion,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      idItem: int.parse(json['idItem'].toString()),
      nomId: int.parse(json['nom_id'].toString()),
      numeroItem: int.parse(json['numero_item'].toString()),
      pregunta: json['pregunta'],
      seccion: json['seccion'],
    );
  }
}
