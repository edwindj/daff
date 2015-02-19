function to_table_view(table, convert){
  var view = (convert)? to_array(table): table;
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

function diff(src, target){
  var alignment = daff.compareTables(src,target).align();
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

function patch_data(table, patch){
  var patcher = new daff.HighlightPatch(table, patch);
  patcher.apply();
  return table;
}

function render_diff(diff, fragment, pretty){
  fragment = !!fragment;
  pretty = !!pretty

  var renderer = new daff.DiffRender();
	renderer.usePrettyArrows(pretty);
	renderer.render(diff);
	if(!fragment) renderer.completeHtml();
	return renderer.html();
}
