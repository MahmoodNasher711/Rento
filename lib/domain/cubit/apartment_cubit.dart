import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/apartment_model.dart';
import 'package:rento/data/repository/firestore_apartment_repository.dart';

part 'apartment_state.dart';

class ApartmentCubit extends Cubit<ApartmentState> {
  final FirestoreApartmentRepository apartmentRepository;

  ApartmentCubit(this.apartmentRepository) : super(ApartmentInitial());

  Future<void> loadApartments() async {
    emit(ApartmentLoading());
    try {
      await validateApartmentsData(); // أولاً: تصحيح البيانات
      final apartments = await apartmentRepository.getAllApartments();
      emit(ApartmentLoaded(apartments));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }

  Future<void> addApartment(ApartmentModel apartment) async {
    try {
      await apartmentRepository.addApartment(apartment);
      emit(ApartmentAdded());
      await loadApartments();
    } catch (e) {
      debugPrint('Error adding apartment: $e'); // أضف هذه السطر
      emit(ApartmentError(e.toString()));
    }
  }
  Future<void> loadApartmentsByFloor(int floorNumber) async {
    emit(ApartmentLoading());
    try {
      final allApartments = await apartmentRepository.getAllApartments();
      final filtered = allApartments.where((a) => a.floorNumber == floorNumber).toList();
      emit(ApartmentLoaded(filtered));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }
  Future<void> updateApartment(ApartmentModel apartment) async {
    try {
      await apartmentRepository.updateApartment(apartment);
      emit(ApartmentUpdated());
      await loadApartments(); // إعادة تحميل القائمة بعد التحديث
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }

  Future<void> deleteApartment(String id) async {
    try {
      await apartmentRepository.deleteApartment(id);
      emit(ApartmentDeleted());
      await loadApartments();
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }
  Future<void> validateApartmentsData() async {
    try {
      final apartments = await apartmentRepository.getAllApartments();

      for (final apartment in apartments) {
        if ((apartment.isRented && apartment.tenantId == null) ||
            (!apartment.isRented && apartment.tenantId != null)) {
          // تصحيح البيانات غير المتزامنة
          await apartmentRepository.updateApartment(
              apartment.copyWith(isRented: apartment.tenantId != null)
          );
        }
      }
    } catch (e) {
      debugPrint('Error validating apartments: $e');
    }
  }
  Future<void> loadRentedApartments() async {
    emit(ApartmentLoading());
    try {
      final apartments = await apartmentRepository.getRentedApartments();
      emit(ApartmentLoaded(apartments));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }

  Future<void> loadVacantApartments() async {
    emit(ApartmentLoading());
    try {
      final apartments = await apartmentRepository.getVacantApartments();
      emit(ApartmentLoaded(apartments));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }
}

