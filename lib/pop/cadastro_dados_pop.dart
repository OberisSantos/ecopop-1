import 'dart:ffi';

import 'package:eco_pop/pop/pop.dart';
import 'package:eco_pop/pop/pop_dao.dart';
import 'package:flutter/material.dart';

class FormularioDadosPop extends StatefulWidget {
  const FormularioDadosPop({Key? key}) : super(key: key);

  @override
  State<FormularioDadosPop> createState() => _FormularioDadosPopState();
}

class _FormularioDadosPopState extends State<FormularioDadosPop> {
  PopDao _popDao = PopDao();

  @override
  Widget build(BuildContext context) {
    final int pop = ModalRoute.of(context)?.settings.arguments as int;

    return Scaffold(
        appBar: AppBar(
          title: Text('Dados do pop'),
        ),
        body: SingleChildScrollView(
          child: _dadosPop(pop),
        ));
  }

  _dadosPop(int pop) {
    return FutureBuilder<Pop?>(
        future: _popDao.getPopId(pop),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: (Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${snapshot.data!.descricao}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration:
                          InputDecoration(hintText: 'Quantidade em estoque'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(hintText: 'Tempo decorrido'),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        DadosPop _dados = DadosPop(
                          0,
                          uuid: null,
                          idPop: snapshot.data,
                          quantidade: null,
                          tempo: null,
                        );
                        _popDao.saveDados(pop, _dados);
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
  /*
  _getPop(int id) async {
    List<Pop> p = await _popDao.findAll();
    var _descricao;
    for (Pop pop in p) {
      if (pop.id == id) {
        _descricao = pop.descricao;
        return FutureBuilder(
            initialData: [],
            future: pop,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return (Card(
                  child: Text(
                    '${_descricao}',
                  ),
                ));
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            });
      }
    }
  }*/
}
