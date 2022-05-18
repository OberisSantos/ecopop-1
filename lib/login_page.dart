import 'package:eco_pop/grupo-pesquisa/lista_grupo.dart';
import 'package:eco_pop/instituicao/lista_instituicao.dart';
import 'package:eco_pop/main.dart';
import 'package:eco_pop/pop/lista_pop.dart';
import 'package:eco_pop/pop/pop_view.dart';
import 'package:eco_pop/user/usuario.dart';
import 'package:eco_pop/user/usuario_dao.dart';
import 'package:eco_pop/utils/network_status_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'dart:developer';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

bool _online = true;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';
  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        //_handleGetContact(_currentUser!);
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'lendo informações sobre o contato';
    });
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = 'A API deu uma resposta ${response.statusCode} '
            '. Verifique os logs para obter detalhes.';
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = 'Você é... $namedContact!';
      } else {
        _contactText = 'Nada para exibir.';
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    _online = await hasNetwork();
    try {
      var user1 = await _googleSignIn.signIn();
      final UsuarioDao uDao = UsuarioDao();
      final Usuario usuario = Usuario(0, user1!.email, user1.displayName);
      print('usario $user1');
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login eCoPoP'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.13,
                      child: ListTile(
                        leading: GoogleUserCircleAvatar(
                          identity: user,
                        ),
                        title: Text(user.displayName ?? ''),
                        subtitle: Text(user.email),
                      ),
                    ),
                    FloatingActionButton.extended(
                      onPressed: _handleSignOut,
                      label: const Text(""),
                      backgroundColor: Colors.green,
                      icon: Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(bottom: 8.0)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 60,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final Future future = Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return MeusDados();
                  }));
                  future.then((usuario) {
                    //teste
                  });
                },
                label: const Text("Meus Dados"),
                backgroundColor: Colors.green,
                icon: Icon(Icons.verified_user),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 8.0)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 60,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final Future future = Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return ListarPop();
                  }));
                  future.then((pop) {
                    //teste
                  });
                },
                label: const Text("Projetos"),
                backgroundColor: Colors.green,
                icon: Icon(Icons.document_scanner),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 8.0)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 60,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final Future future = Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return ListarGruposPesquisa();
                  }));
                  future.then((grupo) {
                    //teste
                  });
                },
                label: const Text("Grupo Pesquisa"),
                backgroundColor: Colors.green,
                icon: Icon(Icons.people),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 8.0)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 60,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final Future future = Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return ListarInstituicao();
                  }));
                  future.then((instituicao) {});
                },
                label: const Text("Instituição"),
                backgroundColor: Colors.green,
                icon: Icon(Icons.account_balance),
              ),
            ),
          ],
        )
      ]);
    } else {
      return Center(
          child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: 200.0,
                height: 200.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    alignment: Alignment.center,
                    image: AssetImage('assets/ECOPoP.png'),
                  ), //AssetImage("assets/Serenity.png"),
                ),
              ),
              SizedBox(
                height: 35.0,
              ),
              FloatingActionButton.extended(
                onPressed: _handleSignIn,
                label: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            ]),
      )); // This trailing comma makes auto-formatting nicer for build methods.
    }
  }
}
