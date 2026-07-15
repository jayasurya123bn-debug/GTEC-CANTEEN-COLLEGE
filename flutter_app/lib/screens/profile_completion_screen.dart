import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pre_order_service.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';
import '../widgets/department_selector.dart';
import '../widgets/year_selector.dart';
import '../widgets/section_selector.dart';

/// Shown as a full-screen modal (or pushed route) when a student attempts
/// to place a pre-order without department/year/section set.
/// Cannot be dismissed until all fields are completed and saved.
class ProfileCompletionScreen extends StatefulWidget {
  /// Called after profile is saved successfully so the caller can proceed.
  final VoidCallback? onCompleted;

  const ProfileCompletionScreen({super.key, this.onCompleted});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _department;
  String? _year;
  String? _section;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    // Validate section (chip selector — not a FormField so check manually)
    if (_section == null) {
      setState(() => _error = 'Please select your section.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() { _saving = true; _error = null; });
    try {
      await PreOrderService.updateStudentProfile(
        department: _department,
        year:       _year,
        section:    _section,
      );

      // Refresh auth provider's user object so the app reflects the new fields
      if (mounted) {
        await Provider.of<AuthProvider>(context, listen: false).refreshUser();
      }

      widget.onCompleted?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to save profile: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent dismissal without completing
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FFF4),
        appBar: AppBar(
          automaticallyImplyLeading: false, // No back button
          backgroundColor: AppTheme.primaryGreen,
          title: const Text(
            '🌿  Complete Your Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your department, year, and section are displayed on your token so canteen staff can organise pickup by department batches.',
                          style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Department
                DepartmentSelector(
                  value: _department,
                  onChanged: (v) => setState(() => _department = v),
                ),
                const SizedBox(height: 20),

                // Year
                YearSelector(
                  value: _year,
                  onChanged: (v) => setState(() => _year = v),
                ),
                const SizedBox(height: 20),

                // Section
                SectionSelector(
                  value: _section,
                  onChanged: (v) => setState(() { _section = v; _error = null; }),
                ),
                const SizedBox(height: 28),

                // Error
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[700], fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Save button
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save & Continue to Pre-Order',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
