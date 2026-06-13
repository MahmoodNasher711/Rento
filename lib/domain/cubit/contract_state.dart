part of 'contract_cubit.dart';

@immutable


abstract class ContractState {}

class ContractInitial extends ContractState {}

class ContractLoading extends ContractState {}

class ContractLoaded extends ContractState {
  final List<ContractModel> contracts;

  ContractLoaded(this.contracts);
}

class ContractAdded extends ContractState {}

class ContractUpdated extends ContractState {}

class ContractDeleted extends ContractState {}

class ContractError extends ContractState {
  final String message;

  ContractError(this.message);
}