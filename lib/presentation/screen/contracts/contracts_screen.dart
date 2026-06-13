import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/domain/cubit/contract_cubit.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../widget/contract_item.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Optionally load contracts when screen is built
    context.read<ContractCubit>().loadContracts();

    return Scaffold(
      appBar: AppBar(
          title: const Text('العقود'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          ],
        ),
        body: BlocBuilder<ContractCubit, ContractState>(
          builder: (context, state) {
            if (state is ContractLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContractError) {
              return Center(child: Text(state.message));
            } else if (state is ContractLoaded) {
              if (state.contracts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment, size: 64, color: AppColors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد عقود مسجلة',
                        style: AppStyles.bodyText1.copyWith(color: AppColors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.contracts.length,
                itemBuilder: (context, index) {
                  final contract = state.contracts[index];
                  return ContractItem(contract: contract);
                },
              );
            }
            return const SizedBox();
          },
        ),
    );
  }
}