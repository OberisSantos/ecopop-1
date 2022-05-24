import 'package:eco_pop/pop/cadastro_dados_pop.dart';
import 'package:eco_pop/pop/pop.dart';
import 'package:eco_pop/pop/pop_dao.dart';
import 'package:flutter/material.dart';

class FormularioPop extends StatefulWidget {
  const FormularioPop({Key? key}) : super(key: key);

  @override
  State<FormularioPop> createState() => _FormularioPopState();
}

class _FormularioPopState extends State<FormularioPop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _descricaoControler = TextEditingController();
  final TextEditingController _conteitoControle = TextEditingController();
  final TextEditingController _fonteControler = TextEditingController();
  final TextEditingController _formulaControler = TextEditingController();
  final TextEditingController _experimentoControler = TextEditingController();
  final TextEditingController _padraoControler = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Pop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: [
          TextFormField(
            controller: _descricaoControler,
            decoration: const InputDecoration(
              icon: Icon(Icons.description),
              hintText: 'Descrição do pop',
              labelText: 'Descrição',
              labelStyle: TextStyle(fontSize: 15.00),
              contentPadding: EdgeInsets.all(8.0),
              hintStyle: TextStyle(fontSize: 15.0),
            ),
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          TextFormField(
            controller: _conteitoControle,
            decoration: const InputDecoration(
              icon: Icon(Icons.design_services_outlined),
              hintText: 'Conceito do pop',
              labelText: 'Conceito',
              labelStyle: TextStyle(fontSize: 15.00),
              contentPadding: EdgeInsets.all(8.0),
              hintStyle: TextStyle(fontSize: 15.0),
            ),
          ),
          TextFormField(
            controller: _fonteControler,
            decoration: const InputDecoration(
              icon: Icon(Icons.font_download),
              hintText: 'Fonte da pesquisa',
              labelText: 'Fonte',
              labelStyle: TextStyle(fontSize: 15.00),
              contentPadding: EdgeInsets.all(8.0),
              hintStyle: TextStyle(fontSize: 15.0),
            ),
          ),
          TextFormField(
            controller: _formulaControler,
            decoration: const InputDecoration(
              icon: Icon(Icons.receipt_long_sharp),
              hintText: 'Fórmula da pesquisa',
              labelText: 'Fórmula',
              labelStyle: TextStyle(fontSize: 15.00),
              contentPadding: EdgeInsets.all(8.0),
              hintStyle: TextStyle(fontSize: 15.0),
            ),
          ),
          TextFormField(
            controller: _experimentoControler,
            decoration: const InputDecoration(
              icon: Icon(Icons.numbers),
              hintText: 'Experimento da pesquisa',
              labelText: 'Experimento',
              labelStyle: TextStyle(fontSize: 15.00),
              contentPadding: EdgeInsets.all(8.0),
              hintStyle: TextStyle(fontSize: 15.0),
            ),
          ),
          TextFormField(
            controller: _padraoControler,
            decoration: const InputDecoration(
              icon: Icon(Icons.padding_sharp),
              hintText: 'Padrão',
              labelText: 'Padrão',
              labelStyle: TextStyle(fontSize: 15.00),
              contentPadding: EdgeInsets.all(8.0),
              hintStyle: TextStyle(fontSize: 15.0),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final String _descricao = _descricaoControler.text;
              final String _conceito = _conteitoControle.text;
              final String _fonte = _fonteControler.text;
              final String _formula = _formulaControler.text;
              final String _experimento = _experimentoControler.text;

              final bool _padrao =
                  _padraoControler.text == 'false' ? false : true;

              final Pop newPop = Pop(
                0,
                uuid: null,
                descricao: _descricao,
                conceito: _conceito,
                fonte: _fonte,
                experimento: _experimento,
                formula: _formula,
                padrao: _padrao,
              );
              //final valor = salvarPop(newPop);
              salvarPop(Pop pop) async {
                final PopDao _podDao = PopDao();
                //var id = await _podDao.savePop(pop);
                var id = 3;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const FormularioDadosPop(),
                    settings: RouteSettings(
                      arguments: id,
                    )));
              }

              salvarPop(newPop);
            },
            child: const Text('Salvar'),
          ),
        ]),
      ),
    );
  }
}
