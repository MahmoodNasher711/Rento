part of 'apartment_cubit.dart';

@immutable

abstract class ApartmentState {}

class ApartmentInitial extends ApartmentState {}

class ApartmentLoading extends ApartmentState {}

class ApartmentLoaded extends ApartmentState {
  final List<ApartmentModel> apartments;

  ApartmentLoaded(this.apartments);
}

class ApartmentAdded extends ApartmentState {}

class ApartmentUpdated extends ApartmentState {}

class ApartmentDeleted extends ApartmentState {}

class ApartmentError extends ApartmentState {
  final String message;

  ApartmentError(this.message);
}