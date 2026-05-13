import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../cubit/settings_cubit.dart';

class TaxSettingsScreen extends StatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  State<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends State<TaxSettingsScreen> {
  late TextEditingController _percentController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsCubit>().state;
    _isEnabled = settings.isTaxEnabled;
    _percentController =
        TextEditingController(text: settings.taxPercent.toString());
  }

  @override
  void dispose() {
    _percentController.dispose();
    super.dispose();
  }

  void _save() {
    final percent = double.tryParse(_percentController.text) ?? 0;
    context.read<SettingsCubit>().updateTaxSettings(_isEnabled, percent);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('save'.tr()), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('taxSettings'.tr()),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            tooltip: 'save'.tr(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _isEnabled,
                        onChanged: (val) => setState(() => _isEnabled = val),
                        title: Text('taxEnabled'.tr()),
                        subtitle:
                            Text(_isEnabled ? 'enabled'.tr() : 'disabled'.tr()),
                        secondary: const Icon(Icons.percent_rounded,
                            color: AppColors.primary),
                      ),
                      if (_isEnabled) ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: AppTextField(
                            label: 'taxPercent'.tr(),
                            controller: _percentController,
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.add_chart_rounded),
                            //suffixText: "%"),
                            suffixIcon: Icon(Icons.percent),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'save'.tr(),
                  icon: Icons.save_rounded,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
