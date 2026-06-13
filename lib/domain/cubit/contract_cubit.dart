import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/contract_model.dart';
import 'package:rento/data/repository/firestore_contract_repository.dart';

part 'contract_state.dart';

class ContractCubit extends Cubit<ContractState> {
  final FirestoreContractRepository contractRepository;

  ContractCubit(this.contractRepository) : super(ContractInitial());

  Future<void> loadContracts() async {
    emit(ContractLoading());
    try {
      final contracts = await contractRepository.getAllContracts();
      emit(ContractLoaded(contracts));
    } catch (e) {
      emit(ContractError(e.toString()));
    }
  }

  Future<void> addContract(ContractModel contract) async {
    try {
      await contractRepository.addContract(contract);
      emit(ContractAdded());
      await loadContracts();
    } catch (e) {
      emit(ContractError(e.toString()));
    }
  }

  Future<void> updateContract(ContractModel contract) async {
    try {
      await contractRepository.updateContract(contract);
      emit(ContractUpdated());
      await loadContracts();
    } catch (e) {
      emit(ContractError(e.toString()));
    }
  }

  Future<void> deleteContract(String id) async {
    try {
      await contractRepository.deleteContract(id);
      emit(ContractDeleted());
      await loadContracts();
    } catch (e) {
      emit(ContractError(e.toString()));
    }
  }

  Future<void> loadContractsByTenant(String tenantId) async {
    emit(ContractLoading());
    try {
      final contracts = await contractRepository.getContractsByTenant(tenantId);
      emit(ContractLoaded(contracts));
    } catch (e) {
      emit(ContractError(e.toString()));
    }
  }
}
