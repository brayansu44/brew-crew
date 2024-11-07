import 'package:brew_crew/models/CustomUser.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constans.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  // form values
  late String _currentName;
  late String _currentSugars;
  late int _currentStrength;

  @override
  void initState() {
    super.initState();
    // Inicializar con valores predeterminados
    _currentName = '';
    _currentSugars = '0';  // Valor predeterminado para azúcar
    _currentStrength = 100; // Valor predeterminado para fuerza
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user!.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData? userData = snapshot.data;

          // Si los valores de la base de datos están disponibles, usarlos
          if (_currentName.isEmpty) {
            _currentName = userData?.name ?? ''; // Valor por defecto vacío si no existe
            _currentSugars = userData?.sugars ?? '0'; // Valor por defecto '0' si no existe
            _currentStrength = userData?.strength ?? 100; // Valor por defecto 100 si no existe
          }

          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  'Update your brew setting.',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  initialValue: userData?.name,
                  decoration: textInputDecoration,
                  validator: (val) => val!.isEmpty ? 'Please enter a name' : null,
                  onChanged: (val) => setState(() => _currentName = val),
                ),
                SizedBox(height: 20.0),
                // dropdown
                DropdownButtonFormField<String>(
                  decoration: textInputDecoration,
                  value: _currentSugars,
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text('$sugar sugars'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _currentSugars = val!),
                ),
                SizedBox(height: 20.0),
                // slider
                Slider(
                  value: _currentStrength.toDouble(),
                  activeColor: Colors.brown[_currentStrength],
                  inactiveColor: Colors.brown[_currentStrength],
                  min: 100.0,
                  max: 900.0,
                  divisions: 8,
                  onChanged: (val) => setState(() => _currentStrength = val.round()),
                ),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.pink[400])),
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await DatabaseService(uid: user.uid).updateUserData(
                        _currentSugars,
                        _currentName,
                        _currentStrength,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }
}
