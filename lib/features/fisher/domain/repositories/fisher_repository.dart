import '../entities/fisher_entities.dart';
import '../../../../core/network/api_models.dart';

abstract interface class BoatRepository {
  Future<List<FisherBoat>> getBoats({PageQuery? query});
  Future<PaginatedResponse<FisherBoat>> getBoatsPage(PageQuery query);
  Future<FisherBoat> saveBoat(FisherBoat boat);
}

abstract interface class FishingTripRepository {
  Future<ActiveFishingTrip?> getActiveTrip();
}

abstract interface class CatchRepository {
  Future<List<FisherCatch>> getCatches();
  Future<FisherCatchReferenceData> getCatchReferenceData();
}

abstract interface class BatchRepository {
  Future<List<FisherBatchSummary>> getBatches();
  Future<FisherBatchDetails> getBatchDetails(String id);
}

/// Role aggregate retained so the existing polished screens share one state
/// owner while still exposing the explicit feature repository boundaries.
abstract interface class FisherRepository
    implements
        BoatRepository,
        FishingTripRepository,
        CatchRepository,
        BatchRepository {}

abstract interface class FisherDraftStore {
  Future<void> saveCatchDraft(FisherCatch value, {required String tripId});
  Future<void> saveBatchDraft(FisherBatchSummary value);
  Future<void> saveTripDraft(ActiveFishingTrip value);
}
