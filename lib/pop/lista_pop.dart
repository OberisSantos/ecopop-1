import 'package:eco_pop/pop/pop.dart';
import 'package:eco_pop/pop/pop_dao.dart';
import 'package:flutter/material.dart';

class ListarPop extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListarPopState();
  }
}

class ListarPopState extends State<ListarPop> {
  final PopDao _popDao = PopDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('População'),
      ),
      body: FutureBuilder<List<Pop>>(
        initialData: [],
        //future: Future.delayed(Duration(seconds: 5))
        future: _popDao.findAll(),
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
              final List<Pop> pops = snapshot.data ?? [];
              return ListView.builder(
                itemBuilder: (context, index) {
                  final Pop pop = pops[index];
                  return MaterialButton(
                    onPressed: () {},
                    child: Card(
                      child: ListTile(
                        title: Text(pop.descricao.toString()),
                        subtitle: Text(pop.conceito.toString()),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                  onPressed: () {
                                    /*Navigator.of(context)
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
                                        );*/
                                  },
                                  icon: Icon(Icons.edit),
                                  color: Colors.orange[300]),
                              IconButton(
                                onPressed: () {
                                  /*
                                  setState(() {
                                    _gruposDao.delete(grupo);
                                  });
                                  */
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
                itemCount: pops.length,
              );
              break;
          }
          return Text('Unknown error');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /*Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => 'FormularioGrupoPesquisa'(),
                  settings: RouteSettings(arguments: null),
                ),
              )
              .then(
                (value) => setState(() {}),
              );
              */
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
