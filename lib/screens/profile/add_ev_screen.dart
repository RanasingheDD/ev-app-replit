import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/api_config.dart';
import '../../providers/ev_provider.dart';
import '../../models/ev.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_overlay.dart';

class AddEvScreen extends StatefulWidget {
  final String? evId;

  const AddEvScreen({super.key, this.evId});

  @override
  State<AddEvScreen> createState() => _AddEvScreenState();
}

class _AddEvScreenState extends State<AddEvScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _batteryController = TextEditingController();
  final _maxChargeController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();

  String? _selectedMake;
  String? _selectedModel;
  int? _selectedYear;
  List<String> _selectedConnectors = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.evId != null;
    if (_isEditing) {
      _loadEv();
    }
  }

  Future<void> _loadEv() async {
    final evProvider = context.read<EVProvider>();
    final ev = evProvider.evs.firstWhere(
      (e) => e.id == widget.evId,
      orElse: () => throw Exception('EV not found'),
    );

    setState(() {
      _nicknameController.text = ev.nickname ?? '';
      _selectedMake = ev.make;
      _selectedModel = ev.model;
      _selectedYear = ev.year;
      _batteryController.text = ev.batteryKwh.toString();
      _maxChargeController.text = ev.maxChargeKw.toString();
      _selectedConnectors = List.from(ev.connectorTypes);
      _vinController.text = ev.vin ?? '';
      _licensePlateController.text = ev.licensePlate ?? '';
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _batteryController.dispose();
    _maxChargeController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  List<String> get _availableModels {
    if (_selectedMake == null) return [];
    final make = popularEVMakes.firstWhere(
      (m) => m.name == _selectedMake,
      orElse: () => EVMake(name: '', models: []),
    );
    return make.models;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedConnectors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one connector type'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final evProvider = context.read<EVProvider>();
    bool success;

    if (_isEditing) {
      success = await evProvider.updateEV(
        widget.evId!,
        make: _selectedMake,
        model: _selectedModel,
        year: _selectedYear,
        batteryKwh: double.parse(_batteryController.text),
        maxChargeKw: double.parse(_maxChargeController.text),
        connectorTypes: _selectedConnectors,
        vin: _vinController.text.isNotEmpty ? _vinController.text : null,
        licensePlate: _licensePlateController.text.isNotEmpty
            ? _licensePlateController.text
            : null,
        nickname: _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
      );
    } else {
      success = await evProvider.addEV(
        make: _selectedMake!,
        model: _selectedModel!,
        year: _selectedYear,
        batteryKwh: double.parse(_batteryController.text),
        maxChargeKw: double.parse(_maxChargeController.text),
        connectorTypes: _selectedConnectors,
        vin: _vinController.text.isNotEmpty ? _vinController.text : null,
        licensePlate: _licensePlateController.text.isNotEmpty
            ? _licensePlateController.text
            : null,
        nickname: _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Vehicle updated' : 'Vehicle added'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(evProvider.error ?? 'Failed to save vehicle'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EVProvider>(
      builder: (context, evProvider, _) {
        return LoadingOverlay(
          isLoading: evProvider.isLoading,
          message: _isEditing ? 'Updating vehicle...' : 'Adding vehicle...',
          child: Scaffold(
            appBar: AppBar(
              title: Text(_isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Nickname (optional)',
                        hintText: 'e.g., My Tesla',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Vehicle Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedMake,
                      decoration: const InputDecoration(
                        labelText: 'Make',
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: popularEVMakes.map((make) {
                        return DropdownMenuItem(
                          value: make.name,
                          child: Text(make.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMake = value;
                          _selectedModel = null;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a make' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedModel,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      items: _availableModels.map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedModel = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a model' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Year (optional)',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: List.generate(10, (i) => DateTime.now().year - i)
                          .map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Battery & Charging',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _batteryController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Battery Capacity',
                              suffixText: 'kWh',
                              prefixIcon: Icon(Icons.battery_full),
                            ),
                            validator: (value) =>
                                Validators.positiveNumber(value, 'Battery capacity'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxChargeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max Charge Rate',
                              suffixText: 'kW',
                              prefixIcon: Icon(Icons.bolt),
                            ),
                            validator: (value) =>
                                Validators.positiveNumber(value, 'Max charge rate'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Connector Types',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConfig.connectorTypes.map((connector) {
                        final isSelected = _selectedConnectors.contains(connector);
                        return FilterChip(
                          label: Text(connector),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedConnectors.add(connector);
                              } else {
                                _selectedConnectors.remove(connector);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Additional Info (optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vinController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'VIN',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _licensePlateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'License Plate',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        child: Text(_isEditing ? 'Update Vehicle' : 'Add Vehicle'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
