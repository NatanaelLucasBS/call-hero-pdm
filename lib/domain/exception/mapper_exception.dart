/// Exceção lançada quando ocorre falha ou inconsistência na conversão entre entidades e modelos de domínio.
class MapperException<From, To> implements Exception {
  final String message;

  MapperException(this.message);

  @override
  String toString() {
    return "Erro ao mapear de $From para $To: $message";
  }
}