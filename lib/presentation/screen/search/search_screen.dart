import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/domain/cubit/apartment_cubit.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../widget/apartment_item.dart';
import '../../widget/tenant_item.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث عن مستأجر أو شقة...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _searchQuery = _searchController.text;
                });
              },
            ),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المستأجرين'),
            Tab(text: 'الشقق'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTenantsTab(),
          _buildApartmentsTab(),
        ],
      ),
    );
  }

  Widget _buildTenantsTab() {
    return BlocBuilder<TenantCubit, TenantState>(
      builder: (context, state) {
        if (state is TenantLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TenantError) {
          return Center(child: Text(state.message));
        } else if (state is TenantLoaded) {
          final filteredTenants = state.tenants
              .where((tenant) =>
          tenant.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              tenant.apartmentNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              tenant.phoneNumber.contains(_searchQuery))
              .toList();

          if (filteredTenants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد نتائج مطابقة للبحث',
                    style: AppStyles.bodyText1.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTenants.length,
            itemBuilder: (context, index) {
              final tenant = filteredTenants[index];
              return TenantItem(tenant: tenant);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildApartmentsTab() {
    return BlocBuilder<ApartmentCubit, ApartmentState>(
      builder: (context, state) {
        if (state is ApartmentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ApartmentError) {
          return Center(child: Text(state.message));
        } else if (state is ApartmentLoaded) {
          final filteredApartments = state.apartments
              .where((apartment) =>
              apartment.number.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          if (filteredApartments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد نتائج مطابقة للبحث',
                    style: AppStyles.bodyText1.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredApartments.length,
            itemBuilder: (context, index) {
              final apartment = filteredApartments[index];
              return ApartmentItem(apartment: apartment);
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}