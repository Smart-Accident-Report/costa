import 'package:flutter/material.dart';

class CreateInsuranceScreen extends StatelessWidget {
  const CreateInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Text('creé votre assurance avec Costa'),
          GestureDetector(
            onTap: () {
              // navigate to camera screen
            },
            child: Container(
              child: Text('Scannee votre permis de conduit'),
            ),
          ),
          GestureDetector(
            onTap: () {
              // navigate to camera screen
            },
            child: Container(
              child: Text('Scannee votre controle technique'),
            ),
          ),
          GestureDetector(
            onTap: () {
              // navigate to vehicule form screen
            },
            child: Container(
              child: Text('Entree les informations de votre vehicule'),
            ),
          ),
          Text('Choisir une societe d\'assurance'),
          //  drop down menu for insurance companies
          Text('Choisir un type d\'assurance'),
          // drop down menu for insurance types "tout risque", "standard"...
          Row(
            children: [
              Text('Avez vous deja une assurance?'),
              TextButton(
                onPressed: () {
                  // navigate to login screen.
                },
                child: Text('Accede a votre compte'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // submit form
            },
            child: Text('Creer mon assurance'),
          ),
        ],
      )),
    );
  }
}
