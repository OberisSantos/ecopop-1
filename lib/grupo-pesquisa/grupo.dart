class GrupoPesquisa {
  final String? uuid;
  final int id;
  final String nomegrupo;

  GrupoPesquisa(this.uuid, this.id, this.nomegrupo);

  @override
  String toString() {
    return 'GrupoPesquisa{uuid:$uuid, id: $id, grupo: $nomegrupo}';
  }
}
