import 'dart:ffi';

class Pop {
  final int id;
  final String? uuid;
  final String? descricao;
  final String? conceito;
  final String? fonte;
  final String? formula;
  final String? experimento;
  final bool padrao;

  Pop(this.id,
      {this.uuid,
      this.descricao,
      this.conceito,
      this.fonte,
      this.formula,
      this.experimento,
      this.padrao = false});

  @override
  String toString() {
    return 'Expo{id: $id, descricao: $descricao}';
  }
}

class DadosPop {
  final int? id;
  final String? uuid;
  final Pop? idPop;
  final Double? quantidade;
  final Double? tempo;

  DadosPop(this.id, {this.uuid, this.idPop, this.quantidade, this.tempo});

  @override
  String toString() {
    return 'Dados{id: $id, Quantidade: $quantidade, Tempo: $tempo, Pop: $idPop}';
  }
}
