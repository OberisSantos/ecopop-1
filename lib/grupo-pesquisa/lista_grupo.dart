import 'package:eco_pop/grupo-pesquisa/cadastro_grupo.dart';
import 'package:eco_pop/grupo-pesquisa/grupo.dart';
import 'package:eco_pop/grupo-pesquisa/grupo_dao.dart';
import 'package:flutter/material.dart';

class ListarGruposPesquisa extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListarGruposPesquisaState();
  }
}

class ListarGruposPesquisaState extends State<ListarGruposPesquisa> {
  final GrupoPesquisaDao _gruposDao = GrupoPesquisaDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Grupo de pesquisa'),
      ),
      body: FutureBuilder<List<GrupoPesquisa>>(
        initialData: [],
        //future: Future.delayed(Duration(seconds: 5))
        //.then((value) => _gruposDao.findAll()),
        future: _gruposDao.findAll(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('Carregando!')
                  ],
                ),
              );
              break;
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              final List<GrupoPesquisa> grupos = snapshot.data ?? [];
              return ListView.builder(
                itemBuilder: (context, index) {
                  final GrupoPesquisa grupo = grupos[index];
                  //return ItensGruposPesquisa(grupo);
                  return MaterialButton(
                    onPressed: () {},
                    child: Card(
                      child: ListTile(
                        title: Text(grupo.nomegrupo),
                        //subtitle: Text(_grupo_pesquisa.id.toString()),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FormularioGrupoPesquisa(),
                                            settings:
                                                RouteSettings(arguments: grupo),
                                          ),
                                        )
                                        .then(
                                          (value) => setState(() {}),
                                        );
                                  },
                                  icon: Icon(Icons.edit),
                                  color: Colors.orange[300]),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _gruposDao.delete(grupo);
                                  });
                                },
                                icon: Icon(Icons.delete),
                                color: Colors.red[900],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: grupos.length,
              );
              break;
          }
          return Text('Unknown error');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => FormularioGrupoPesquisa(),
                  settings: RouteSettings(arguments: null),
                ),
              )
              .then(
                (value) => setState(() {}),
              );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
