class PagerDto<T> {
  ///same to jQuery DataTables
  final int draw;
  ///return totalRows
  final int recordsFiltered;
  ///return page rows
  final List<T> data;

  PagerDto({required this.draw, required this.recordsFiltered, required this.data});

  ///convert json string to PagerVo model
  ///無法使用 factory constructor 省略第2個參數 !!
  ///@jsonStr
  ///@fromJson static function parameter !!
  factory PagerDto.fromJson(Map<String, dynamic>json, Function fromJson) {
    var list = (json['data'] == null) ? [] : json['data'] as List;
    var rows = list.map((row) => fromJson(row)).cast<T>().toList(); //has cast<>

    return PagerDto(
      draw: json['draw'],
      recordsFiltered: json['recordsFiltered'],
      data: rows,
    );
  }
  
}//class