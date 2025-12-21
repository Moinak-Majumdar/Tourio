import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tourio/db/tour_db.dart';
import 'package:tourio/models/tour_model.dart';

class TourController extends GetxController {
  final RxList<TourModel> tours = <TourModel>[].obs;
  final RxDouble expenseCount = 0.0.obs;
  final RxInt tourCount = 0.obs;

  static const _ongoingKey = 'ongoing_tour_id';
  final _box = GetStorage();

  final RxInt ongoingTourId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTours();
    _loadOngoing();
  }

  // ---------------- Tours ----------------

  Future<void> _loadTours() async {
    final res = await Future.wait([TourDb.getAllTours()]);

    tours.assignAll(res[0]);
    expenseCount.value = 0.0;
    tourCount.value = res[0].length;
  }

  Future<void> refreshTours() async {
    await _loadTours();
  }

  // ---------------- Ongoing Tour ----------------

  void _loadOngoing() {
    ongoingTourId.value = _box.read<int>(_ongoingKey) ?? 0;
  }

  void setOngoing(int tourId) {
    ongoingTourId.value = tourId;
    _box.write(_ongoingKey, tourId);
  }

  void clearOngoing() {
    ongoingTourId.value = 0;
    _box.remove(_ongoingKey);
  }

  TourModel? get ongoingTour {
    if (ongoingTourId.value == 0) return null;
    return tours.firstWhereOrNull((t) => t.id == ongoingTourId.value);
  }
}
