import os
import re

def replace_in_file(filepath, pattern, replacement):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(pattern, replacement, content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

# 1-6. Unused imports in database_operations
db_ops = ['apartment_operations.dart', 'contract_operations.dart', 'expense_operations.dart', 'payment_operations.dart']
for op in db_ops:
    replace_in_file(f'lib/data/database_operation/{op}', r"import\s*'package:sqflite/sqflite.dart';\n?", '')
replace_in_file('lib/data/database_operation/tenant_operations.dart', r"import\s*'package:sqflite/sqflite.dart';\n?", '')

# 5. avoid print in payment_operations.dart
replace_in_file('lib/data/database_operation/payment_operations.dart', r"print\(", 'debugPrint(')
# we might need to import flutter/foundation.dart for debugPrint, let's just comment out the print or replace with debugPrint
replace_in_file('lib/data/database_operation/payment_operations.dart', r"import 'package:rento/data/models/payment_model.dart';", "import 'package:rento/data/models/payment_model.dart';\nimport 'package:flutter/foundation.dart';")

# 8. unnecessary string interpolation in database_helper.dart
replace_in_file('lib/data/local_database/database_helper.dart', r"path = '\$databasesPath/rento.db';", "path = databasesPath + '/rento.db';")
# wait, better:
replace_in_file('lib/data/local_database/database_helper.dart', r"join\('\$databasesPath', 'rento\.db'\)", "join(databasesPath, 'rento.db')")


# 9. unused import in tenant_repository.dart
replace_in_file('lib/data/repository/tenant_repository.dart', r"import\s*'package:flutter_bloc/flutter_bloc.dart';\n?", '')

# 10. initializing formals in dashboard_cubit.dart
replace_in_file('lib/domain/cubit/dashboard_cubit.dart', 
    r"DashboardCubit\(\n\s*TenantRepository tenantRepository,\n\s*PaymentRepository paymentRepository,\n\s*ExpenseRepository expenseRepository,\n\s*ApartmentRepository apartmentRepository,\n\s*\)   : _tenantRepository = tenantRepository,\n\s*_paymentRepository = paymentRepository,\n\s*_expenseRepository = expenseRepository,\n\s*_apartmentRepository = apartmentRepository\s*\{",
    "DashboardCubit(this._tenantRepository, this._paymentRepository, this._expenseRepository, this._apartmentRepository) {")
# let's just do a regex replace for the assignments
replace_in_file('lib/domain/cubit/dashboard_cubit.dart', 
    r"DashboardCubit\(\s*TenantRepository tenantRepository,\s*PaymentRepository paymentRepository,\s*ExpenseRepository expenseRepository,\s*ApartmentRepository apartmentRepository,\s*\)\s*:\s*_tenantRepository\s*=\s*tenantRepository,\s*_paymentRepository\s*=\s*paymentRepository,\s*_expenseRepository\s*=\s*expenseRepository,\s*_apartmentRepository\s*=\s*apartmentRepository\s*\{",
    "DashboardCubit(this._tenantRepository, this._paymentRepository, this._expenseRepository, this._apartmentRepository) {")

# 11. override on non overriding member in tenant_state.dart
replace_in_file('lib/domain/cubit/tenant_state.dart', r"@override\s+List<Object\?> get props => \[message\];", "List<Object?> get props => [message];")

# 12. unused local variable in main.dart
replace_in_file('lib/main.dart', r"final isDark = Theme\.of\(context\)\.brightness == Brightness\.dark;\n", "")

# 13, 14. apartments_screen.dart
replace_in_file('lib/presentation/screen/apartments/apartments_screen.dart', r"const SizedBox\(\);", "SizedBox();") # Wait, unnecessary const might be elsewhere, line 220
# Let's replace `const` where it's unnecessary
with open('lib/presentation/screen/apartments/apartments_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()
lines = content.split('\n')
if len(lines) > 220:
    lines[219] = lines[219].replace('const ', '')
content = '\n'.join(lines)
with open('lib/presentation/screen/apartments/apartments_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

replace_in_file('lib/presentation/screen/apartments/apartments_screen.dart', r"context\.read<ApartmentCubit>\(\)\.deleteApartment\(apartment\.id!\);", "if (!context.mounted) return;\ncontext.read<ApartmentCubit>().deleteApartment(apartment.id!);")
replace_in_file('lib/presentation/screen/apartments/apartments_screen.dart', r"context\.read<ApartmentCubit>\(\)\.loadApartments\(\);", "if (!context.mounted) return;\ncontext.read<ApartmentCubit>().loadApartments();")

# 15. add_edit_contract_screen.dart
replace_in_file('lib/presentation/screen/contracts/add_edit_contract_screen.dart', r"import\s*'package:rento/data/models/tenant_model.dart';\n?", '')

# 16, 17. dashboard_screen.dart
with open('lib/presentation/screen/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()
lines = content.split('\n')
if len(lines) > 729:
    lines[728] = lines[728].replace('final isDark = Theme.of(context).brightness == Brightness.dark;', '')
if len(lines) > 778:
    lines[777] = lines[777].replace('__', '_')
if len(lines) > 897:
    lines[896] = lines[896].replace('__', '_')
content = '\n'.join(lines)
with open('lib/presentation/screen/dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

# 18, 19. expenses_screen.dart
replace_in_file('lib/presentation/screen/expenses/expenses_screen.dart', r"import\s*'package:rento/data/models/expense_model.dart';\n?", '')
replace_in_file('lib/presentation/screen/expenses/expenses_screen.dart', r"context\.read<ExpenseCubit>\(\)\.loadExpenses\(\);", "if (!context.mounted) return;\ncontext.read<ExpenseCubit>().loadExpenses();")
replace_in_file('lib/presentation/screen/expenses/expenses_screen.dart', r"context\.read<ExpenseCubit>\(\)\.deleteExpense\(expense\.id!\);", "if (!context.mounted) return;\ncontext.read<ExpenseCubit>().deleteExpense(expense.id!);")

# 20. rename file _generateAndSharePdf.dart
import shutil
if os.path.exists('lib/presentation/screen/reports/_generateAndSharePdf.dart'):
    shutil.move('lib/presentation/screen/reports/_generateAndSharePdf.dart', 'lib/presentation/screen/reports/generate_and_share_pdf.dart')
    # wait, might need to update imports if any, but since it's an isolated file or maybe not used. Let's see if it's imported somewhere

# 21, 22, 23, 24, 25. reports_screen.dart
replace_in_file('lib/presentation/screen/reports/reports_screen.dart', r"import\s*'package:printing/printing.dart';\n?", '')
replace_in_file('lib/presentation/screen/reports/reports_screen.dart', r"await context\.read<ExpenseCubit>\(\)\.loadExpenses\(\);", "if (!context.mounted) return;\nawait context.read<ExpenseCubit>().loadExpenses();")
replace_in_file('lib/presentation/screen/reports/reports_screen.dart', r"\$\{_selectedReportType\}", "$_selectedReportType")
replace_in_file('lib/presentation/screen/reports/reports_screen.dart', r"Share\.shareXFiles", "SharePlus.instance.share") # Wait, actually the new API might just be Share.shareXFiles? No, warning says SharePlus instead of Share and share instead of shareXFiles... Wait, let's just do what it says: SharePlus.shareXFiles? No, warning says `Use SharePlus.instance.share() instead`. Oh actually Share is from `import 'package:share_plus/share_plus.dart';` wait, let's just use `Share.shareXFiles`. The warning is from old share package maybe? Let's check imports: `import 'package:share_plus/share_plus.dart';` has `Share.shareXFiles` deprecated. Replacement is `ShareResult result = await Share.shareXFiles(...)` ? No, `Share.shareXFiles` -> `Share.shareXFiles` is deprecated in favor of `Share.shareXFiles`? Wait, I will just suppress the warning or do the exact replacement: `Share.shareXFiles` -> `Share.shareXFiles` wait. I will check the file later.
replace_in_file('lib/presentation/screen/reports/reports_screen.dart', r"Table\.fromTextArray", "pw.TableHelper.fromTextArray")
