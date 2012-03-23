$.ext.Class.namespace('$.datagrid.classes');
$.datagrid.classes.TextEditor = $.ext.Class.create($.datagrid.classes.Editor, {

  createComponent: function(td, initialValue){
    var input = $('<input />').val(initialValue);
    input.focus(function(){ this.select(); });
    td.html(input);
    return input;
  }

});