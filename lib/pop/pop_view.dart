import 'dart:math';

import 'package:eco_pop/grupo-pesquisa/cadastro_grupo.dart';
import 'package:eco_pop/pop/pop.dart';
import 'package:eco_pop/pop/pop_dao.dart';
import 'package:flutter/material.dart';
import 'package:simple_line_chart/simple_line_chart.dart';

class VerPop extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VerPopState();
  }
}

class VerPopState extends State<VerPop> {
  final PopDao _popDao = PopDao();

  late final LineChartData data;

  @override
  void initState() {
    super.initState();
    data = LineChartData(datasets: [
      Dataset(label: 'População', dataPoints: _createDataPoints()),
    ]); // create a data model
  }

  List<DataPoint> _createDataPoints() {
    //final snapshot = await _popDao.findDadosFB('https://ecop-25-d01d5-default-rtdb.firebaseio.com/projetos_padrao/EXPO/dados');
    List<DataPoint> dataPoints = [];
    dataPoints.add(DataPoint(x: 0.0, y: 0.0));
    dataPoints.add(DataPoint(x: 100.0, y: 150.0));
    dataPoints.add(DataPoint(x: 200.0, y: 500.0));
    dataPoints.add(DataPoint(x: 300.0, y: 4000.0));
    /*var i=0;
    while ( i < snapshot.length ){
      dataPoints.add(DataPoint(x: snapshot.elementAt(i)['tempo'], y: snapshot.elementAt(i)['estoque']));
      i = i +1;
    }*/
    return dataPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Proj População'),
      ),
      body: FutureBuilder<Pop>(
        //initialData: null,
        //future: Future.delayed(Duration(seconds: 5))
        //.then((value) => _gruposDao.findAll()),
        future: _popDao.findPopFB('projetos_padrao/EXPO'),
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
              final Pop? pop = snapshot.data;
              return Column(
                children: [
                  MaterialButton(
                    onPressed: () {},
                    child: Card(
                      child: ListTile(
                        title:
                            Text(pop != null ? pop.descricao.toString() : ""),
                        //subtitle: Text(pop!=null?pop.experimento!=null?pop.experimento:""):""),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 18.0, left: 12.0, top: 24, bottom: 12),
                    child: LineChart(
                        // chart is styled
                        style: LineChartStyle.fromTheme(context),
                        seriesHeight: 300,
                        // chart has data
                        data: data),
                  ),
                ],
              );
          }
          return Text('Unknown error');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) =>
                      FormularioGrupoPesquisa(), //TODO: FormularioPop()
                  settings: RouteSettings(arguments: null),
                ),
              )
              .then(
                (value) => setState(() {}),
              );
        },
        child: Icon(Icons.update),
      ),
    );
  }
}
