function to_table_view(table){
  var view = to_array(table);
  return new daff.TableView(view);
}

function to_array(table){
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

function to_objects(x){
  var keys = x[0];
  var result = [];
  for (var i=1; i < x.length; i++){
    result.push(_.object(keys, x[i]))
  }
  return result;
}
