import 'hero_network_entity.dart';

/// DTO que mapeia o envelope de resposta paginada da API.
class HttpPagedResult {
  final int first;
  final dynamic prev;
  final int? next;
  final int last;
  final int pages;
  final int items;
  final List<HeroNetworkEntity> data;

  HttpPagedResult({
    required this.first,
    required this.prev,
    this.next,
    required this.last,
    required this.pages,
    required this.items,
    required this.data,
  });

  /// Converte o Map da resposta paginada em objeto tipado com a lista de heróis.
  factory HttpPagedResult.fromJson(Map<String, dynamic> json) {
    return HttpPagedResult(
      first: json['first'] as int? ?? 1,
      prev: json['prev'],
      next: json['next'] as int?,
      last: json['last'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
      items: json['items'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => HeroNetworkEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}