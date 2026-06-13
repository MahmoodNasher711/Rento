part of 'dashboard_cubit.dart';

@immutable
abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final int rentedApartmentsCount;
  final int vacantApartmentsCount;
  final double totalRents;
  final double totalExpenses;
  final int latePaymentsCount;
  final int endingContractsCount;

  const DashboardLoaded({
    required this.rentedApartmentsCount,
    required this.vacantApartmentsCount,
    required this.totalRents,
    required this.totalExpenses,
    required this.latePaymentsCount,
    required this.endingContractsCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardLoaded &&
        other.rentedApartmentsCount == rentedApartmentsCount &&
        other.vacantApartmentsCount == vacantApartmentsCount &&
        other.totalRents == totalRents &&
        other.totalExpenses == totalExpenses &&
        other.latePaymentsCount == latePaymentsCount &&
        other.endingContractsCount == endingContractsCount;
  }

  @override
  int get hashCode {
    return rentedApartmentsCount.hashCode ^
    vacantApartmentsCount.hashCode ^
    totalRents.hashCode ^
    totalExpenses.hashCode ^
    latePaymentsCount.hashCode ^
    endingContractsCount.hashCode;
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}