import 'package:eco_pop/instituicao/instituicao.dart';
import 'package:eco_pop/instituicao/instituicao_dao.dart';
import 'package:flutter/material.dart';

class FormularioInstituicao extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  State<StatefulWidget> createState() {
    return FormularioInstituicaoState();
  }
}

class FormularioInstituicaoState extends State<FormularioInstituicao> {
  final InstituicaoDao _instituicaoDao = InstituicaoDao();
  final TextEditingController _controladorDescricao = TextEditingController();
  final TextEditingController _controladorSigla = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Instituicao? instituicaoUp =
        ModalRoute.of(context)?.settings.arguments as Instituicao?;

    if (instituicaoUp != null) {
      _controladorDescricao.text = instituicaoUp.descricao;
      if (instituicaoUp.sigla != null) {
        _controladorSigla.text = instituicaoUp.sigla!;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Instituição'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'O campo não pode ficar vazio';
                    } else {
                      return null;
                    }
                  },
                  controller: _controladorDescricao,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Descrição da instituição',
                    //labelText: 'Descrição do grupo',
                    contentPadding: const EdgeInsets.all(8.0),
                  ),
                ),
                TextFormField(
                  controller: _controladorSigla,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Sigla da instituição',
                    //labelText: 'Descrição do grupo',
                    contentPadding: const EdgeInsets.all(8.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (instituicaoUp != null) {
                          final String descricao = _controladorDescricao.text;
                          final String sigla = _controladorSigla.text;
                          final String? uuid = instituicaoUp.uuid == null
                              ? null
                              : instituicaoUp.uuid;
                          final int id = instituicaoUp.id;

                          final Instituicao upInstituicao = Instituicao(
                              uuid: uuid,
                              id: id,
                              descricao: descricao,
                              sigla: sigla);
                          //update
                          _instituicaoDao
                              .update(upInstituicao)
                              .then((id) => Navigator.pop(context));
                        } else {
                          final String descricao = _controladorDescricao.text;
                          final String sigla = _controladorSigla.text;
                          final Instituicao newInstituicao = Instituicao(
                              uuid: null,
                              id: 0,
                              descricao: descricao,
                              sigla: sigla);
                          //Salvar
                          _instituicaoDao
                              .save(newInstituicao)
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

  String? _validarNome(String value) {
    if (value.length == 0) {
      return "Campo obrigatório";
    }

    return null;
  }
}
