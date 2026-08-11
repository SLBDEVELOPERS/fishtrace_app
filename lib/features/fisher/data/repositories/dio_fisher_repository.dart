import 'package:fishtrace/core/models/models.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_models.dart';
import '../../../../core/network/api_support.dart';
import '../../domain/entities/fisher_entities.dart';
import '../../domain/repositories/fisher_repository.dart';
import '../dtos/fisher_dtos.dart';

class DioFisherRepository implements FisherRepository {
  DioFisherRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<FisherBoat>> getBoats({PageQuery? query}) async => _list(
    ApiEndpoints.boats,
    (json) => FisherBoatDto.fromJson(json).toDomain(),
    query: query?.toQuery(),
  );

  @override
  Future<PaginatedResponse<FisherBoat>> getBoatsPage(PageQuery query) async {
    final response = await _api.get(ApiEndpoints.boats, query: query.toQuery());
    final items = ApiData.list(response)
        .map((json) => FisherBoatDto.fromJson(json).toDomain())
        .toList(growable: false);
    final Map<String, Object?> envelope = response is Map
        ? ApiData.map(response)
        : const {};
    final Map<String, Object?> pagination = envelope['data'] is Map
        ? ApiData.map(envelope['data'])
        : envelope;
    return PaginatedResponse(
      items: items,
      currentPage: ApiData.integer(pagination, 'currentPage', query.page),
      lastPage: ApiData.integer(pagination, 'lastPage', query.page),
      total: ApiData.integer(pagination, 'total', items.length),
    );
  }

  @override
  Future<List<FisherCatch>> getCatches() async => _list(
    ApiEndpoints.catches,
    (json) => FisherCatchDto.fromJson(json).toDomain(),
  );

  @override
  Future<FisherCatchReferenceData> getCatchReferenceData() async {
    final response = await _api.get(ApiEndpoints.fisherReferenceData);
    final envelope = ApiData.map(response);
    final data = envelope['data'] is Map
        ? ApiData.map(envelope['data'])
        : envelope;
    return FisherCatchReferenceData(
      species: ApiData.listValue(data, 'species')
          .map(ApiData.map)
          .map(
            (item) => FisherSpeciesReference(
              id: ApiData.string(item, 'id'),
              commonName: ApiData.string(item, 'commonName'),
              scientificName: ApiData.string(item, 'scientificName'),
            ),
          )
          .where((item) => item.id.isNotEmpty && item.commonName.isNotEmpty)
          .toList(growable: false),
      gearTypes: ApiData.listValue(data, 'gearTypes')
          .map(ApiData.map)
          .map((item) => ApiData.string(item, 'name'))
          .where((name) => name.isNotEmpty)
          .toList(growable: false),
    );
  }

  @override
  Future<List<FisherBatchSummary>> getBatches() async => _list(
    ApiEndpoints.batches,
    (json) => FisherBatchDto.fromJson(json).toDomain(),
  );

  @override
  Future<FisherBatchDetails> getBatchDetails(String id) async {
    final responses = await Future.wait([
      _api.get(ApiEndpoints.batch(id)),
      _api.get(ApiEndpoints.batchTimeline(id)),
      _api.get(ApiEndpoints.batchDocuments(id)),
    ]);
    final detailEnvelope = ApiData.map(responses[0]);
    final detail = ApiData.map(detailEnvelope['data'] ?? detailEnvelope);
    return FisherBatchDetailsDto.fromJson(
      detail,
      timeline: ApiData.list(responses[1]),
      documents: ApiData.list(responses[2]),
    ).toDomain();
  }

  @override
  Future<ActiveFishingTrip?> getActiveTrip() async {
    final response = await _api.get(
      ApiEndpoints.fishingTrips,
      query: const {
        'status': 'ACTIVE',
        'per_page': 1,
        'sort': 'departed_at',
        'direction': 'desc',
      },
    );
    final items = ApiData.list(response);
    if (items.isEmpty) return null;
    final trip = ActiveFishingTripDto.fromJson(items.first).toDomain();
    if (trip.status != TripStatus.inProgress) return null;
    return trip;
  }

  @override
  Future<FisherBoat> saveBoat(FisherBoat boat) async {
    final body = FisherBoatDto.fromDomain(boat);
    // Server-side boat identifiers are UUIDs. Older app builds generated new
    // local boats as BOAT-..., so keep accepting that prefix while those
    // cached drafts are still present on devices.
    final isLocal = boat.id.startsWith('LOCAL-') || boat.id.startsWith('BOAT-');

    final response = isLocal
        ? await _api.post(ApiEndpoints.boats, data: body)
        : await _api.put(ApiEndpoints.boat(boat.id), data: body);
    return FisherBoatDto.fromJson(
      ApiData.map(
        response is Map && response.containsKey('data')
            ? response['data']
            : response,
      ),
    ).toDomain();
  }

  Future<List<T>> _list<T>(
    String path,
    T Function(Map<String, Object?>) parser, {
    Map<String, Object?>? query,
  }) async {
    final response = await _api.get(path, query: query);
    return ApiData.list(response).map(parser).toList();
  }
}
