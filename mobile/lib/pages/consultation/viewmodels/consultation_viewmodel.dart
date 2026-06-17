import 'package:get/get.dart';
import '../models/consultation_model.dart';
import '../services/consultation_service.dart';

class ConsultationViewModel extends GetxController {
  final RxInt selectedPatientId = 0.obs;
  final RxList<Consultation> consultations = <Consultation>[].obs;
  final RxList<Treatment> treatments = <Treatment>[].obs;
  final RxList<Prescription> prescriptions = <Prescription>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTooth = (-1).obs;
  final RxString selectedFace = ''.obs;

  void selectTooth(int toothNumber) {
    if (selectedTooth.value == toothNumber) {
      selectedTooth.value = -1;
      selectedFace.value = '';
    } else {
      selectedTooth.value = toothNumber;
      selectedFace.value = '';
    }
  }

  void selectFace(String face) => selectedFace.value = face;

  Future<void> loadForPatient(int patientId) async {
    selectedPatientId.value = patientId;
    isLoading.value = true;
    try {
      final results = await Future.wait([
        ConsultationService.getConsultations(patientId),
        ConsultationService.getTreatments(patientId),
        ConsultationService.getPrescriptions(patientId),
      ]);
      consultations.assignAll(results[0] as List<Consultation>);
      treatments.assignAll(results[1] as List<Treatment>);
      prescriptions.assignAll(results[2] as List<Prescription>);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTreatment(Treatment t) async {
    final Treatment created = await ConsultationService.addTreatment(t);
    treatments.insert(0, created);
  }

  Future<void> addPrescription(Prescription p) async {
    final Prescription created = await ConsultationService.addPrescription(p);
    prescriptions.insert(0, created);
  }
}
