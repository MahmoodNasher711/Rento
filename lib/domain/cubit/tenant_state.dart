part of 'tenant_cubit.dart';

@immutable

abstract class TenantState {}

class TenantInitial extends TenantState {}

class TenantLoading extends TenantState {}

class TenantLoaded extends TenantState {
  final List<TenantModel> tenants;

  TenantLoaded(this.tenants);
}
class TodayAlertsLoaded extends TenantState {
  final List<TodayAlert> alerts;

  TodayAlertsLoaded(this.alerts);
}
class TenantAdded extends TenantState {}

class TenantUpdated extends TenantState {}

class TenantDeleted extends TenantState {}
class TodayAlertsEmpty extends TenantState {
  
  List<Object> get props => [];
}
class TenantError extends TenantState {
  final String message;

  TenantError(this.message);
}
