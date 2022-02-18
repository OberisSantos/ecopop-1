import 'package:eco_pop/View/grupo-pesquisa/grupo_dao.dart';
import 'package:eco_pop/view/grupo-pesquisa/grupo.dart';
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
  //final TextEditingController _controladorCampoNome = TextEditingController();

  _loadFormData(grupo) {
    if (grupo != null) {
      return grupo.nomegrupo;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    //final GrupoPesquisa = ModalRoute.of(context).settings.arguments;
    //final GrupoPesquisa? grupoUpdate = widget.grupo;
    final GrupoPesquisa? grupoUpdate =
        ModalRoute.of(context)?.settings.arguments as GrupoPesquisa?;
    //  ModalRoute.of(context)?.settings.arguments as GrupoPesquisa?;
    final TextEditingController _controladorCampoNome =
        TextEditingController(text: _loadFormData(grupoUpdate));

    return Scaffold(
      appBar: AppBar(
        title: Text('Criando Grupo de Pesquisa'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 20.0),
          child: Column(
            children: [
              TextFormField(
                //initialValue: 'teste',
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
                    if (grupoUpdate != null) {
                      final String nomegrupo = _controladorCampoNome.text;
                      final int id = grupoUpdate.id;

                      final GrupoPesquisa upGrupoPesquisa =
                          GrupoPesquisa(id, nomegrupo);
                      //update
                      _grupoDao
                          .update(upGrupoPesquisa)
                          .then((id) => Navigator.pop(context));
                    } else {
                      final String nomegrupo = _controladorCampoNome.text;

                      final GrupoPesquisa newGrupoPesquisa =
                          GrupoPesquisa(0, nomegrupo);
                      //Salvar
                      _grupoDao
                          .save(newGrupoPesquisa)
                          .then((id) => Navigator.pop(context));
                    }
                  },
                  child: Text('Confirmar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
