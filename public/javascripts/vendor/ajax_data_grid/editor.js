$.ext.Class.namespace('$.datagrid.classes');
$.datagrid.classes.Editor = $.ext.Class.create({

  logger: $.jqLog.logger('$.datagrid.classes.Editor'),

  initialize: function(grid, column, options) {
    this.grid = grid;
    this.options = options;
    this.column = column;
    this.editing = false;
  },

  createComponent: function() {
  },

//  loadValue: function(value) {
//    this.component.val(value);
//  },

  getInitialValue: function() {
//    var value = this.td.data(this.column.binding_path);
    var value = this.td.attr("data-"+this.column.binding_path);
    if($.isUndefined(value)) value = "";
    return value;
  },

  startEditing: function(td) {
    if (this.editing) {
      this.logger.warn('startEditing when already ediitng');
      return;
    }

    this.td = td;

    this.original = {
      tdHtml: td.html(),
      value: this.getInitialValue(td)
    };

    this.component = this.createComponent(td, this.original.value);

    td.addClass('editing');

    this.setSize(td.outerWidth(), td.outerHeight());
    this.focus();

    this.editing = true;
  },

  setSize: function(width, height) {
    this.component.outerWidth(width).outerHeight(height-1); //-1 is because of border-collapse for td, so it won't make input bigger 1 pixel and cause height change glitch
//    this.component.outerWidth(width);
  },

  focus: function() {
    this.component.focus();
  },

  cancelEditing: function() {
    if (!this.editing) return;
    this.stopEditing();
  },

  stopEditing: function() {
    if (!this.editing) return;

    this.td.html(this.original.tdHtml);
    this.td.removeClass('editing');
    this.editing = false;
    this.td = this.component = this.original = null;
  },

  hasEditingValueChanged: function() {
    var newValue = this.getEditingValue();
    return newValue != this.original.value;
  },

  getEditingValue: function() {
    return this.component.val();
  },

  getSaveValue: function(){
    var result = {};
    result[this.column.binding_path] = this.getEditingValue();
    return result;
  }


});