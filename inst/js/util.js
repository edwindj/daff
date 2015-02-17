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

function diff(table1, table2){
  var alignment = daff.compareTables(table1,table2).align();
  var flags = new daff.CompareFlags();
  var highlighter = new daff.TableDiff(alignment,flags);
  var data_diff = [];
  var table_diff = new daff.TableView(data_diff);
  highlighter.hilite(table_diff);
  return table_diff;
}

function to_csv(table){
  var csv = new daff.Csv();
  return csv.renderTable(table);
}

function from_csv(txt){
  var csv = new daff.Csv();
  var output = new daff.SimpleTable(0,0);
	csv.parseTable(txt,output);
	if(output != null) output.trimBlank();
	return output;
}
