class RespuestaItem {
  final int evaluacionId;
  final int itemId;
  final String aplica;
  final String cumple;
  final String observaciones;
  final int valor;

  RespuestaItem({
    required this.evaluacionId,
    required this.itemId,
    required this.aplica,
    required this.cumple,
    required this.observaciones,
    required this.valor,
  });

  factory RespuestaItem.fromJson(Map<String, dynamic> json) {
    return RespuestaItem(
      evaluacionId: json['evaluacion_id'],
      itemId: json['item_id'],
      aplica: json['aplica'],
      cumple: json['cumple'],
      observaciones: json['observaciones'],
      valor: json['valor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "evaluacion_id": evaluacionId,
      "item_id": itemId,
      "aplica": aplica,
      "cumple": cumple,
      "observaciones": observaciones,
      "valor": valor,
    };
  }
}
