import 'package:eco_pop/grupo-pesquisa/grupo_dao.dart';
import 'package:eco_pop/grupo-pesquisa/grupo.dart';
import 'package:flutter/material.dart';

class FormularioGrupoPesquisa extends StatefulWidget {
  //final GrupoPesquisa? grupo;

  //FormularioGrupoPesquisa(this.grupo, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  State<StatefulWidget> createState() {
    return FormularioGrupoPesquisaState();
  }
}

class FormularioGrupoPesquisaState extends State<FormularioGrupoPesquisa> {
  final GrupoPesquisaDao _grupoDao = GrupoPesquisaDao();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _controladorCampoNome = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //final GrupoPesquisa = ModalRoute.of(context).settings.arguments;
    //final GrupoPesquisa? grupoUp = widget.grupo;
    final GrupoPesquisa? grupoUp =
        ModalRoute.of(context)?.settings.arguments as GrupoPesquisa?;
    //  ModalRoute.of(context)?.settings.arguments as GrupoPesquisa?;

    if (grupoUp != null) {
      _controladorCampoNome.text = grupoUp.nomegrupo;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Criando Grupo de Pesquisa'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  //initialValue: 'teste',
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'O campo não pode ficar vazio';
                    } else {
                      return null;
                    }
                  },
                  controller: _controladorCampoNome,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),

                  decoration: InputDecoration(
                    hintText: 'Descrição do grupo',
                    //labelText: 'Descrição do grupo',
                    contentPadding: const EdgeInsets.all(8.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      //_criaGrupoPesquisa(context);
                      if (_formKey.currentState!.validate()) {
                        if (grupoUp != null) {
                          final String nomegrupo = _controladorCampoNome.text;
                          final int id = grupoUp.id;
                          final String? uuid =
                              grupoUp.uuid == null ? null : grupoUp.uuid;

                          final GrupoPesquisa upGrupoPesquisa =
                              GrupoPesquisa(uuid, id, nomegrupo);
                          //update
                          _grupoDao
                              .update(upGrupoPesquisa)
                              .then((id) => Navigator.pop(context));
                        } else {
                          final String nomegrupo = _controladorCampoNome.text;

                          final GrupoPesquisa newGrupoPesquisa =
                              GrupoPesquisa(null, 0, nomegrupo);
                          //Salvar
                          _grupoDao
                              .save(newGrupoPesquisa)
                              .then((id) => Navigator.pop(context));
                        }
                      }
                    },
                    child: Text('Confirmar'),
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
