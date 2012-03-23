$.ext.Class.namespace('$.datagrid.classes');
$.datagrid.classes.ComboboxEditor = $.ext.Class.create($.datagrid.classes.Editor, {

  createComponent: function(td, selectedValue){
    this.comboboxAPI = td.combobox({
      empty: false,
      items: this.options.items, selectedValue: selectedValue,
      events: {
        context: this,
        hide: this._onComboboxPopupClosed
      }
    }).combobox('api');

    return this.comboboxAPI.el;
  },

  focus: function(){
    this.comboboxAPI.showPopup();
  },

  getEditingValue: function() {
    return this.comboboxAPI.selectedValue();
  },

  _onComboboxPopupClosed: function(){
    this.grid.commitEdit();
  }

});
