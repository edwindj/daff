function to_table_view(table){
  var view = []

  if (table.length == 0){
    return view;
  }

  view.push(_.keys(table[0]));

  for (var i=0; i < table.length; i++){
    view.push(_.values(table[i]))
  }
  return view;
}
