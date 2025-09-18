import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/create_insurance_bloc.dart';

class CreateInsuranceScreen extends StatefulWidget {
  const CreateInsuranceScreen({super.key});

  @override
  State<CreateInsuranceScreen> createState() => _CreateInsuranceScreenState();
}

class _CreateInsuranceScreenState extends State<CreateInsuranceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCompany;
  String? _selectedType;
  String? _carDocumentsUrl;

  // Mock data for dropdowns
  final List<String> _insuranceCompanies = [
    'CAAT',
    'SAA',
    'CAAR',
    'CNMA',
    'Salama Assurances'
  ];
  final List<String> _insuranceTypes = [
    'standard',
    'auto professionnelle',
    'tous risques'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: BlocConsumer<CreateInsuranceBloc, CreateInsuranceState>(
              listener: (context, state) {
                if (state is CreateInsuranceSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Insurance created successfully!')),
                  );
                } else if (state is CreateInsuranceFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Créez votre assurance avec Costa',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    // Document Scanning Buttons
                    ElevatedButton(
                      onPressed: () {
                        // Logic to trigger camera for scanning
                        // For MVP, just mock a URL
                        setState(() {
                          _carDocumentsUrl = 'mocked_doc_url_123';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Car documents scanned!')),
                        );
                      },
                      child: const Text('Scanner les documents du véhicule'),
                    ),
                    const SizedBox(height: 20),
                    // Insurance Company Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Choisir une société d\'assurance',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCompany,
                      items: _insuranceCompanies.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCompany = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a company';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Insurance Type Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Choisir un type d\'assurance',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedType,
                      items: _insuranceTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an insurance type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Submit button
                    ElevatedButton(
                      onPressed: state is! CreateInsuranceLoading
                          ? () {
                              if (_formKey.currentState!.validate() &&
                                  _carDocumentsUrl != null) {
                                BlocProvider.of<CreateInsuranceBloc>(context)
                                    .add(
                                  CreateInsuranceSubmitted(
                                    company: _selectedCompany!,
                                    type: _selectedType!,
                                    carDocumentsUrl: _carDocumentsUrl!,
                                  ),
                                );
                              } else if (_carDocumentsUrl == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please scan car documents first')),
                                );
                              }
                            }
                          : null,
                      child: state is CreateInsuranceLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Créer mon assurance'),
                    ),
                  ],
                  //add finger print scan after clicking on the button
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
