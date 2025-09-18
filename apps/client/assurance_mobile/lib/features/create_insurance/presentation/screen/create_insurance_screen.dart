import 'package:flutter/material.dart';
import 'camera_scan_screen.dart';

class CreateInsuranceScreen extends StatefulWidget {
  const CreateInsuranceScreen({super.key});

  @override
  State<CreateInsuranceScreen> createState() => _CreateInsuranceScreenState();
}

class _CreateInsuranceScreenState extends State<CreateInsuranceScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  final _formKeys = List.generate(3, (index) => GlobalKey<FormState>());

  int _currentStep = 0;

  // Document scanning states
  bool _carteGriseScanned = false;
  bool _drivingLicenseScanned = false;

  // Extracted data from documents
  Map<String, dynamic> _extractedCarData = {};
  Map<String, dynamic> _extractedDriverData = {};

  // User input data
  String? _selectedPuissanceMoteur;
  String? _selectedNombrePlaces;
  String? _selectedMarque;
  String? _selectedModele;
  String? _selectedAnnee;
  String? _selectedWilaya;
  String? _selectedAssistanceType;
  String? _selectedDuree;
  // ignore: unused_field
  double? _valeurVenale;
  bool _paymentCCP = false;
  bool _isUnder25 = false;
  bool _isPermitOverAYear = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      _formKeys[_currentStep].currentState!.save();
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Handle form submission
        _showSuccessDialog();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).cardColor,
                  Theme.of(context).cardColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Assurance Créée avec Succès!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre demande d\'assurance a été soumise avec succès. Vous recevrez une confirmation par email.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Terminé'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _scanDocument(String documentType) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScanScreen(documentType: documentType),
      ),
    );

    if (result != null) {
      setState(() {
        if (documentType == 'carte_grise') {
          _carteGriseScanned = true;
          _extractedCarData = result;
          // Auto-fill form fields
          _selectedMarque = result['marque'];
          _selectedModele = result['modele'];
          _selectedAnnee = result['annee'];
          _selectedWilaya = result['wilaya'];
        } else if (documentType == 'permis_conduire') {
          _drivingLicenseScanned = true;
          _extractedDriverData = result;
        }
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text('Document scanné avec succès'),
            ],
          ),
          backgroundColor: Theme.of(context).cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Row(
        children: [
          ...List.generate(3, (index) {
            final isActive = _currentStep >= index;
            //final isCurrent = _currentStep == index;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  if (index < 2) const SizedBox(width: 8),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScanButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isScanned,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isScanned
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: isScanned ? 2 : 1,
              ),
              gradient: isScanned
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isScanned
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isScanned ? Icons.check_circle : icon,
                    color: isScanned
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.titleSmall,
        ),
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        dropdownColor: Theme.of(context).cardColor,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildCustomTextField({
    required String label,
    String? initialValue,
    TextInputType? keyboardType,
    FormFieldSetter<String>? onSaved,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.titleSmall,
        ),
        initialValue: initialValue,
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildCustomCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                    color: value
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: value
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoPage() {
    return Form(
      key: _formKeys[0],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations du véhicule',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scannez votre carte grise ou saisissez manuellement',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              // Scan button
              _buildScanButton(
                title: 'Scanner la carte grise',
                subtitle: 'Extraction automatique des données',
                icon: Icons.camera_alt,
                onTap: () => _scanDocument('carte_grise'),
                isScanned: _carteGriseScanned,
              ),

              const SizedBox(height: 24),

              // Manual input fields
              _buildCustomDropdown(
                label: 'Puissance Moteur',
                items: [
                  '3-4cv',
                  '5-6cv',
                  '7-10cv',
                  '11-14cv',
                  '15-23 cv',
                  '24cv+'
                ],
                value: _selectedPuissanceMoteur,
                onChanged: (value) =>
                    setState(() => _selectedPuissanceMoteur = value),
                validator: (value) => value == null
                    ? 'Veuillez sélectionner une puissance'
                    : null,
              ),

              _buildCustomDropdown(
                label: 'Nombre de places',
                items: ['3', '4', '5', '7'],
                value: _selectedNombrePlaces,
                onChanged: (value) =>
                    setState(() => _selectedNombrePlaces = value),
                validator: (value) => value == null
                    ? 'Veuillez sélectionner le nombre de places'
                    : null,
              ),

              _buildCustomTextField(
                label: 'Marque',
                initialValue: _selectedMarque ?? _extractedCarData['marque'],
                onSaved: (value) => _selectedMarque = value,
                validator: (value) =>
                    value?.isEmpty == true ? 'Veuillez saisir la marque' : null,
              ),

              _buildCustomTextField(
                label: 'Modèle',
                initialValue: _selectedModele ?? _extractedCarData['modele'],
                onSaved: (value) => _selectedModele = value,
                validator: (value) =>
                    value?.isEmpty == true ? 'Veuillez saisir le modèle' : null,
              ),

              _buildCustomTextField(
                label: 'Année',
                initialValue: _selectedAnnee ?? _extractedCarData['annee'],
                keyboardType: TextInputType.number,
                onSaved: (value) => _selectedAnnee = value,
                validator: (value) =>
                    value?.isEmpty == true ? 'Veuillez saisir l\'année' : null,
              ),

              _buildCustomTextField(
                label: 'Valeur vénale du véhicule',
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _valeurVenale = double.tryParse(value ?? ''),
                validator: (value) => value?.isEmpty == true
                    ? 'Veuillez saisir la valeur vénale'
                    : null,
              ),

              _buildCustomTextField(
                label: 'Wilaya',
                initialValue: _selectedWilaya ?? _extractedCarData['wilaya'],
                onSaved: (value) => _selectedWilaya = value,
                validator: (value) =>
                    value?.isEmpty == true ? 'Veuillez saisir la wilaya' : null,
              ),

              const SizedBox(height: 16),

              _buildCustomCheckbox(
                title: 'Paiement par facilité (CCP)',
                value: _paymentCCP,
                onChanged: (value) => setState(() => _paymentCCP = value!),
              ),

              _buildCustomCheckbox(
                title: 'Avez-vous moins de 25 ans ?',
                value: _isUnder25,
                onChanged: (value) => setState(() => _isUnder25 = value!),
              ),

              _buildCustomCheckbox(
                title: 'Âge de permis plus d\'une année ?',
                value: _isPermitOverAYear,
                onChanged: (value) =>
                    setState(() => _isPermitOverAYear = value!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssistancePage() {
    return Form(
      key: _formKeys[1],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type d\'assistance',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez la formule qui vous convient',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),

              _buildCustomDropdown(
                label: 'Formule d\'assistance',
                items: [
                  'Formule Tranquillité',
                  'Formule Tranquillité Plus',
                  'Formule Liberté'
                ],
                value: _selectedAssistanceType,
                onChanged: (value) =>
                    setState(() => _selectedAssistanceType = value),
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner une formule' : null,
              ),

              _buildCustomDropdown(
                label: 'Durée',
                items: ['6 mois', '1 année'],
                value: _selectedDuree,
                onChanged: (value) => setState(() => _selectedDuree = value),
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner une durée' : null,
              ),

              // Insurance formula cards
              const SizedBox(height: 24),
              _buildFormulaCard(
                'Tranquillité',
                'Couverture de base avec assistance 24h/7j',
                ['Dépannage', 'Remorquage', 'Assistance juridique'],
                _selectedAssistanceType == 'Formule Tranquillité',
                () => setState(
                    () => _selectedAssistanceType = 'Formule Tranquillité'),
              ),

              _buildFormulaCard(
                'Tranquillité Plus',
                'Couverture étendue avec services premium',
                [
                  'Tous services Tranquillité',
                  'Véhicule de remplacement',
                  'Rapatriement'
                ],
                _selectedAssistanceType == 'Formule Tranquillité Plus',
                () => setState(() =>
                    _selectedAssistanceType = 'Formule Tranquillité Plus'),
              ),

              _buildFormulaCard(
                'Liberté',
                'Couverture complète tous risques',
                [
                  'Tous services précédents',
                  'Vol et incendie',
                  'Bris de glace'
                ],
                _selectedAssistanceType == 'Formule Liberté',
                () =>
                    setState(() => _selectedAssistanceType = 'Formule Liberté'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormulaCard(String title, String description,
      List<String> features, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: isSelected ? 2 : 1,
              ),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: 2,
                        ),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            feature,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverInfoPage() {
    return Form(
      key: _formKeys[2],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations du conducteur',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scannez votre permis ou saisissez manuellement',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              // Scan button
              _buildScanButton(
                title: 'Scanner le permis de conduire',
                subtitle: 'Extraction automatique des données',
                icon: Icons.credit_card,
                onTap: () => _scanDocument('permis_conduire'),
                isScanned: _drivingLicenseScanned,
              ),

              const SizedBox(height: 24),

              _buildCustomTextField(
                label: 'Nom',
                initialValue: _extractedDriverData['nom'],
                onSaved: (value) => _extractedDriverData['nom'] = value,
                validator: (value) =>
                    value?.isEmpty == true ? 'Veuillez saisir le nom' : null,
              ),

              _buildCustomTextField(
                label: 'Prénom',
                initialValue: _extractedDriverData['prenom'],
                onSaved: (value) => _extractedDriverData['prenom'] = value,
                validator: (value) =>
                    value?.isEmpty == true ? 'Veuillez saisir le prénom' : null,
              ),

              _buildCustomTextField(
                label: 'Date de naissance',
                initialValue: _extractedDriverData['date_naissance'],
                onSaved: (value) =>
                    _extractedDriverData['date_naissance'] = value,
                validator: (value) => value?.isEmpty == true
                    ? 'Veuillez saisir la date de naissance'
                    : null,
              ),

              _buildCustomTextField(
                label: 'Numéro de permis',
                initialValue: _extractedDriverData['num_permis'],
                onSaved: (value) => _extractedDriverData['num_permis'] = value,
                validator: (value) => value?.isEmpty == true
                    ? 'Veuillez saisir le numéro de permis'
                    : null,
              ),

              _buildCustomTextField(
                label: 'Date de permis',
                initialValue: _extractedDriverData['date_permis'],
                onSaved: (value) => _extractedDriverData['date_permis'] = value,
                validator: (value) => value?.isEmpty == true
                    ? 'Veuillez saisir la date de permis'
                    : null,
              ),

              _buildCustomTextField(
                label: 'Type de permis',
                initialValue: _extractedDriverData['type_permis'],
                onSaved: (value) => _extractedDriverData['type_permis'] = value,
                validator: (value) => value?.isEmpty == true
                    ? 'Veuillez saisir le type de permis'
                    : null,
              ),

              _buildCustomTextField(
                label: 'Numéro de châssis',
                initialValue: _extractedCarData['num_chassis'],
                onSaved: (value) => _extractedCarData['num_chassis'] = value,
                validator: (value) => value?.isEmpty == true
                    ? 'Veuillez saisir le numéro de châssis'
                    : null,
              ),

              _buildCustomTextField(
                label: 'Énergie',
                initialValue: _extractedCarData['energie'],
                onSaved: (value) => _extractedCarData['energie'] = value,
                validator: (value) => value?.isEmpty == true
                    ? 'Veuillez saisir l\'énergie'
                    : null,
              ),

              _buildCustomDropdown(
                label: 'Type de matricule',
                items: ['provisoire', 'permanent 11 digits', '10 digits'],
                value: _extractedCarData['type_matricule'],
                onChanged: (value) =>
                    setState(() => _extractedCarData['type_matricule'] = value),
                validator: (value) => value == null
                    ? 'Veuillez sélectionner le type de matricule'
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créer une assurance',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.security),
                onPressed: () {},
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildVehicleInfoPage(),
                  _buildAssistancePage(),
                  _buildDriverInfoPage(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Précédent'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_currentStep < 2 ? 'Suivant' : 'Terminer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
