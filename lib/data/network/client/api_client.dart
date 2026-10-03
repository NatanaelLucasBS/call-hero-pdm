import 'package:dio/dio.dart';

import '../../../domain/exception/network_exception.dart';
import '../entity/hero_network_entity.dart';
import '../entity/http_paged_result.dart';

/// Cliente HTTP da aplicação utilizando a biblioteca Dio (Aula 06).
class ApiClient {
  late final Dio _dio;

  /// Configura a URL base e o interceptor de logs de requisições e respostas.
  ApiClient({required String baseUrl}) {
    _dio = Dio()
      ..options.baseUrl = baseUrl
      ..interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
  }

  /// Busca lista paginada de heróis no json-server para o catálogo infinito (Slide 5).
  Future<List<HeroNetworkEntity>> getHeroes({int? page, int? limit}) async {
    final response = await _dio.get(
      "/heroes",
      queryParameters: {
        '_page': ?page,
        '_limit': ?limit,
        '_per_page': ?limit,
      },
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      throw NetworkException(
        statusCode: response.statusCode!,
        message: response.statusMessage,
      );
    } else if (response.statusCode != null) {
      if (response.data is List) {
        return (response.data as List)
            .map((e) => HeroNetworkEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final HttpPagedResult receivedData = HttpPagedResult.fromJson(
        response.data as Map<String, dynamic>,
      );
      return receivedData.data;
    } else {
      throw Exception('Erro desconhecido na comunicação com a API');
    }
  }

  /// Busca os dados completos de um único herói pelo seu ID (Slides 6 e 7).
  Future<HeroNetworkEntity> getHeroById(int id) async {
    final response = await _dio.get("/heroes/$id");

    if (response.statusCode != null && response.statusCode! >= 400) {
      throw NetworkException(
        statusCode: response.statusCode!,
        message: response.statusMessage,
      );
    } else if (response.statusCode != null) {
      return HeroNetworkEntity.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Erro ao buscar o herói de ID: $id');
    }
  }
}
