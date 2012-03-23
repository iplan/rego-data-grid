$.ext.Class.namespace('$.datagrid.classes');
$.datagrid.classes.DataGrid = $.ext.Class.create({
  include: [$.ext.mixins.Observable],

  initialize: function(config){
    var self = this;

    this.initialConfig = config || {};
    jQuery.extend(this, this.initialConfig);

    if(!this.server_params) throw 'Server params must be present for datagrid to initialize';
    if(!this.columns) throw 'Columns must be present for datagrid to initialize';

    this.logger = $.jqLog.logger('$.datagrid.classes.DataGrid');
    this.id = this.server_params.grid_id;

    this.selectors = $.extend({}, {
      multirow_actions: 'div.multirow_actions[data-grid-id={0}]'.format(this.id),
      pageSize: 'div.pageSize[data-grid-id={0}]'.format(this.id),
      pagination: 'div.pages[data-grid-id={0}] div.pagination'.format(this.id),
      table: 'div.grid_table[data-grid-id={0}] table'.format(this.id),
      grid: 'div.grid[data-grid-id={0}]'.format(this.id)
    });

    if(!this.paramsModelName) this.paramsModelName = 'model';

    this.editing = false;

    this.columnsById = {};
    this.columns.each(function(column){ self.columnsById[column.id] = column; });

    this.attachAPI();
  },

  init: function(){
    this.initEvents();
  },

  attachAPI: function(){
    $(this.selectors.table).closest('div.grid_table').data('api', this);
  },

  initEvents: function(){
    this.initSelectionColumnEvents();
    this.initDestroyColumnEvents();
    this.initPagingEvents();
    this.initGridEditingEvents();
    this.initNoDataEvents();
    this.initSortableColumns();
    this.initMultiRowActions();
  },

  initSelectionColumnEvents: function(){
    var self = this;
    var cbAll = $('thead th.selection', self.selectors.table).live('click', function(){
      var th = $(this);
      var cb = th.find('span.checkbox');
      self.toggleAllRowsSelection(!cb.hasClass('selected'));
    }).find('span.checkbox');

    $('tbody td.selection', self.selectors.table).live('click', function(){
      var td = $(this);
      var cb = td.find('span.checkbox');
      cb.toggleClass('selected');
      td.closest('tr.row').toggleClass('selected', cb.hasClass('selected'));

      //toggle the header toggler
      var allSelected = $('tbody tr.row', self.selectors.table).length == $('tbody tr.row.selected', self.selectors.table).length;
      cbAll.toggleClass('selected', allSelected);

      self.fire('selectionChanged');
    });

    this.on('selectionChanged', this.onSelectionChanged, this);
  },

  initDestroyColumnEvents: function(){
    var self = this;

    $('tbody td.destroy a', self.selectors.table).live('click', function(e){
      var a = $(this);
      var td = a.closest('td');
      var tr = td.closest('tr.row');
      var rowId = tr.data('id');
      var colIndex = td.index();
      var column = self.columns[colIndex];
      var url = a.attr('href');
      if(column.jq_dialog_confirm){
        td.addClass('confirming');
        $.dialog.show({
          position: {of: td},
          type: 'confirm',
          events: {
            hide: function(){ td.removeClass('confirming') },
            yes: function(){ self.performEntityRemove(rowId, url); }
          }
        });
      }else {
        if(a.data('confirm_message') && a.data('confirm_message').length > 0){
          td.addClass('confirming');
          var answer = confirm(a.data('confirm_message'));
          if(answer) {
            self.performEntityRemove(rowId, url);
          }
          td.removeClass('confirming');
        }
      }
      e.stopEvent();
      return false;
    });
  },

  initPagingEvents: function(){
    var self = this;

    //init page size combobox
    $('select', self.selectors.pageSize).live('change', function(){
      var value = $(this).val();
      var params = {};
      params[$(this).attr('name')] = value;
      self.updateGridWithAjax(params);
    });

    //init paging buttons
    $('a', self.selectors.pagination).live('click', function(){
      var href = $(this).attr('href');
      self.updateGridWithAjax({paging_current_page: $.query.load(href).keys.paging_current_page});
      return false;
    });
  },

  initGridEditingEvents: function(){
    var self = this;
    //init grid clicks to invoke editors
    $('tbody', self.selectors.table).live('click', function(e){
      if(self.editing || self.isLoading()) return;

      var td = $(e.target).closest('td.editable');
      //self.logger.info(td);
      if(td.length == 0 || td.hasClass('working') || td.hasClass('editing')) return;

      if(td.hasClass('dialog_editor')){
        self.startDialogEditing(td);
      } else if(td.hasClass('fbox_editor')){
        self.startFancyboxEditing(td);
      } else {
        self.startEditing(td);
      }
    });

    //init validation error ok link
    $('tbody tr td.error div.validation-error div.message a', self.selectors.table).live('click', function(e){
      var td = $(this).closest('td');
      td.html(td.find('div.original').html());
      td.removeClass('error');
      return false;
    });

    //init keynav class that will be added to active editing cell
    this.editingKeyNav = $.keyNav({
      scope: this,
      enter: function(){
        this.commitEdit();
      },
      esc: function(){
        this.cancelEditing();
      }
    });
  },

  initNoDataEvents: function(){
    var self = this;

    //clear filter button
    $('tr.no-data div.no .clearFilter', this.selectors.grid).live('click', function(){
      if(self.manual_clear_filter){
        self.fire('clearFilter');
      } else {
        if(self.urls.clear_filter) window.location = self.urls.clear_filter;
        else window.location.reload();
      }
    });
  },

  initSortableColumns: function(){
    var self = this;
    $('thead th.sortable', this.selectors.table).live('click', function(){
      self.sortByColumn($(this).index());
    });
  },

  initMultiRowActions: function(){
    var self = this;

    //init close button
    $(self.selectors.multirow_actions).find('a.close').live('click', function(){
      self.clearRowsSeleciton();
    });

    //init dialog multi edit buttons
    $(self.selectors.multirow_actions).find('a.dialog').live('click', function(){
      if(!self.hasSelectedRows()) return;

      var columnId = $(this).data('column_id');
      var dialogType = $(this).data('dialog_type');

      var column = self.columnsById[columnId];
      var columnIndex = column.index;

      var trs = self.getSelectedRows();
      var tds = trs.find('>td:eq({0})'.format(columnIndex));

      $.dialog.show({
          position: {of: $(this)},
          content: {trs: trs, col: columnIndex},
          type: dialogType,
          events: {
              context: self,
              approve: function(event, returnData){
                  self.logger.info('approve click');
                  if(returnData == null) return;

                  var params = {ids: [], column_id: columnId, grid_id: self.id, data: returnData};
                  trs.each(function(){ params.ids.push($(this).data('id')); });

                  self.toggleCellSaving(tds, true);
                  $.ajax({
                      url: self.urls.update_multiple,
                      type: 'post',
                      dataType: 'script',
                      data: $.param(params),
                      error: function(xhr){
                          self.logger.info('error');
                      },
                      complete: function(){
                          self.toggleCellSaving(tds, false);
                      }
                  });
              }
          }
      });
    });
  },

  isLoading: function(){
    $(this.selectors.grid).hasClass('loading');
  },

  toggleLoading: function(isLoading){
    $(this.selectors.grid).toggleClass('loading', isLoading);
  },

  toggleCellSaving: function(td, isLoading){
    if(isLoading == td.hasClass('working')) return; //do nohting
    if(isLoading){ //show 'saving...' spinner and put cell original contents into div.original (this is necessary so if error occurs, original content can be reverted to)
      var originalHTML = null;
      if(td.find('div.validation-error').length > 0){ //error is displayed, get original content from div.original
        originalHTML = td.find('div.validation-error div.original').html();
      } else {
        originalHTML = td.html();
      }
      var savingHTML = this.getTemplateTDContents('saving'); //$('<div class="saving"><span class="text"/><div class="original"/></div>');
//      savingHTML.find('.message').html(this.i18n.saving);
      savingHTML.find('div.original').html(originalHTML);
      td.html(savingHTML);
      td.addClass('working');
    } else {
      if(td.find('div.saving').length > 0){
        td.html(td.find('div.saving div.original').html());
      }
      td.removeClass('working');
    }
  },

  hasSelectedRows: function(){
    return $('tbody tr.row.selected', this.selectors.table).length > 0
  },

  getSelectedRows: function(){
    return $('tbody tr.row.selected', this.selectors.table);
  },

  clearRowsSeleciton: function(){
    this.toggleAllRowsSelection(false);
  },

  toggleAllRowsSelection: function(selected){
    var cb = $('thead th.selection span.checkbox', this.selectors.table);
    cb.toggleClass('selected', selected);
    $('tbody tr.row', this.selectors.table).each(function(){
      var tr = $(this);
      tr.toggleClass('selected', selected);
      tr.find('td.selection span.checkbox').toggleClass('selected', selected);
    });
    this.fire('selectionChanged');
  },

  sortByColumn: function(colIndex){
    var self = this;

    var column = this.columns[colIndex];
    var th = $('thead th:eq({0})'.format(colIndex), this.selectors.table);
    var params = {sort_by: th.data('sort-by'),  sort_direction: th.data('sort-direction')};
    this.logger.info('column {0} sort: by {1} in order {2}'.format(colIndex, params.sort_by, params.sort_direction));

    this.updateGridWithAjax(params);
  },

  //params must be a hash object {...}
  //callbacks are hash of methods (key is one of $.ajax event name, value is function)
  updateGridWithAjax: function(params, callbacks){
    if(!$.isPlainObject(callbacks)) callbacks = {};
    callbacks = $.extend({beforeSend: Function.emptyFn, success: Function.emptyFn, error: Function.emptyFn, complete: Function.emptyFn}, callbacks);

    var self = this;
    params = $.extend({}, this.server_params, params);
    params = $.param(params);
    this.toggleLoading(true);
    $.ajax({
      url: this.urls.update_grid,
      dataType: 'script',
      data: params,
      beforeSend: function(){ callbacks.beforeSend.apply(callbacks.beforeSend, arguments); },
      error: function(){ callbacks.error.apply(callbacks.error, arguments); },
      success: function(){
        callbacks.success.apply(callbacks.success, arguments);
      },
      complete: function(){ callbacks.complete.apply(callbacks.complete, arguments); }
    });
  },

  performEntityRemove: function(recordId, url){
    var self = this;

    this.markRowAsDestroying(recordId);
    this.toggleLoading(true); //show grid spinner

    $.ajax({
      url: url,
      dataType: 'script',
      type: 'post',
      data: $.param($.extend({_method: 'delete'}, this.server_params)),
      success: function(){
        self.fire('updatedWithAjax');
        self.reinitQtips();
      }
    });
  },

  performFilter: function(values, callbacks){
    var params = $.extend(values, {paging_current_page: 1}); //when filtering, reset to page 1
    this.updateGridWithAjax(params, callbacks);
  },

  reinitQtips: function(){
    if(this.reinit_qtip && iPlan.ui.util.QTipIntializer) iPlan.ui.util.QTipIntializer.init(this.selectors.grid);
  },

  markRowAsDestroying: function(rowId){
    //show row spinner
    var tr = $(this.selectors.table).find('tbody tr[data-id={0}]'.format(rowId));
    var tbody = tr.closest('tbody');
    var insertIndex = tr.index()-1;
    var rowTitle = tr.data('row_title');

    var templateTR = this.getTemplateTR('destroying').addClass('working');
    templateTR.find('td .row_title').html(rowTitle);
    templateTR.find('.original').html(tr);
    templateTR.attr('data-id', rowId);
    templateTR.insertAfter(tbody.find('tr:eq({0})'.format(insertIndex)));
//    tr.replaceWith(templateTR);
  },

  addCreatingRow: function(rowUID, message){
    var templateTR = this.getTemplateTR('creating').addClass('working');
    templateTR.attr('data-row_uid', rowUID);
    templateTR.find('td .row_title').html(message);
    templateTR.insertAfter($(this.selectors.table).find('tbody tr.template').last());
    $(this.selectors.table).removeClass('empty');
  },

  removeCreatingRow: function(tr){
    tr.remove();
    var table = $(this.selectors.table);
    table.toggleClass('empty', (table.find('tbody tr.row').length + table.find('tbody tr.working').not('.template').length) == 0);
  },

  getTemplateTR: function(type){
    var tr = $(this.selectors.table).find('tr.template').filter('.'+type);
    if(tr.length == 0) throw "Data grid template row of type '{0}' not found".format(type);
    return tr.clone().removeClass('template');
  },

  getTemplateTDContents: function(type){
    var trCellTemplates = this.getTemplateTR('cell_templates');
    var td = trCellTemplates.find('td.'+type);
    if(td.length == 0) throw "Data grid template cell of type '{0}' not found".format(type);
    return $(td.html());
  },

  getEditorClass: function(type){
    if(type == 'text') return $.datagrid.classes.TextEditor;
    else if(type == 'combobox') return $.datagrid.classes.ComboboxEditor;
    else throw 'Unsupported editor type: ' + type;
  },

  startDialogEditing: function(td){
    var colIndex = td.index();
    var column = this.columns[colIndex];
    var dialogType = column.editor.type;

    $.dialog.show({
      position: {of: td},
      content: {td: td},
      type: dialogType,
      events: {
        context: this,
        buttonClick: function(buttonName, event, returnData){
          this.logger.info('buttonClick:' + buttonName);
          this.saveDialogValue(td, returnData);
        },
        hide: function(){
          this.stopDialogEditing();
        }
      }
    });
    td.addClass('editing');

    this.editing = {
      td: td
    };
  },

  startFancyboxEditing: function(td){
    var self = this;
    var removeEditingClassFunction = function(){ td.removeClass('editing'); };

    var colIndex = td.index();
    var column = this.columns[colIndex];
    var url = column.editor.url;

    var tr = td.closest('tr');
    var recordId = tr.data('id');
    url = url.replace("_0_", recordId);

    $.fancybox(
      $.extend({ href: url, ajax: {data: {grid_id: this.id}}, onClosed: removeEditingClassFunction, onCancel: removeEditingClassFunction}, FancyBoxInitalizer.config.forms.fancybox)
    );
    td.addClass('editing');
  },

  startEditing: function(td){
    var colIndex = td.index();
    var column = this.columns[colIndex];
    var editorClass = this.getEditorClass(column.editor.type);
    var editor = new editorClass(this, column, column.editor);
    editor.startEditing(td);
    this.editingKeyNav.bind(td);

    this.editing = {
      td: td,
      editor: editor
    };

    $(document).bind('mousedown', {grid: this}, this.onDocumentMouseDown);

    td.addClass('editing');
  },

  commitEdit: function(){
    if(!this.editing) return;

    var editor = this.editing.editor;
    if(editor.hasEditingValueChanged()){
      var newValue = editor.getSaveValue();
      var td = editor.td;
      this.stopEditing();

      this.saveCellValue(td, newValue);
    } else {
      this.cancelEditing();
    }
  },

  cancelEditing: function(){
    if(!this.editing) return;

    var editor = this.editing.editor;
    editor.cancelEditing();
    this.stopEditing();
  },

  stopEditing: function(){
    if(!this.editing) return;

    var editor = this.editing.editor;
    editor.stopEditing();

    var td = this.editing.td;
    this.editingKeyNav.unbind(td);

    $(document).unbind('mousedown', this.onDocumentMouseDown);
    td.removeClass('editing');
    this.editing = false;
  },

  stopDialogEditing: function(){
    var td = this.editing.td;
    this.editingKeyNav.unbind(td);
    td.removeClass('editing');
    this.editing = false;
  },

  getEditingValue: function(){
    if(!this.editing) return;
    return this.editing.editor.val();
  },

  saveDialogValue: function(td, dialogReturnData){
    if(dialogReturnData != null){
      this.saveCellValue(td, dialogReturnData);
    }
  },

  saveCellValue: function(td, attributeValuesHash){
    var self = this;
    
    var tr = td.closest('tr');
    var recordId = tr.data('id');    
    this.toggleCellSaving(td, true);

    var colIndex = td.index();
    var column = this.columns[colIndex];
    var params = {
      grid_id: this.id,
      column_id: column.id,
      //related_cols: column.editor.related_cols || [],
      _method: 'put'
    };
    params[this.paramsModelName] = attributeValuesHash;

    $.ajax({
      url: this.urls.update_cell.replace("_0_", "{0}").format(recordId),
      type: 'post',
      dataType: 'script',
      data: $.param(params),
      error: function(xhr){
        td.addClass('error');
        td.html("{0}: {1}".format(xhr.status, xhr.statusText))
      },
      complete: function(){
        self.toggleCellSaving(td, false);
      }
    });
  },

  onAjaxUpdateGrid: function(newGridHtml, server_params){
    $(this.selectors.grid).replaceWith(newGridHtml);
    this.attachAPI();
    this.reinitQtips();
    this.fire('updatedWithAjax');
    this.server_params = server_params;
  },

  onAjaxUpdateRowCell: function(rowId, columnId, newTableHtml){
    var self = this;
    var trSelector = 'tbody tr[data-id={0}]'.format(rowId);
    var originalTR = $(this.selectors.table).find(trSelector);
    var newTR = newTableHtml.find(trSelector);

    var column = this.columnsById[columnId];
    var cols = [columnId].concat(column.editor.related_cols || []).collect(function(colId){ return self.columnsById[colId] ? self.columnsById[colId].index : null }).select(function(colIndex){ return colIndex != null; });
    cols.collect(function(colIndex){ return {originalTD: originalTR.find('>td').eq(colIndex), newTD: newTR.find('>td').eq(colIndex)}; }).each(function(datum){
      datum.originalTD.replaceWith(datum.newTD); //cant simply replace with each, need to use datum, 'cause replaceWith breaks col indices in newTR
      if(self.reinit_qtip) iPlan.ui.util.QTipIntializer.init(datum.newTD)
    });
    originalTR.data('row_title', newTR.data('row_title'));
  },

  onAjaxUpdateRow: function(rowId, newTableHtml){
    var self = this;
    var trSelector = 'tbody tr[data-id={0}]'.format(rowId);
    var originalTR = $(this.selectors.table).find(trSelector);
    var newTR = newTableHtml.find(trSelector);
    var originalOddEvenClass = originalTR.hasClass('odd') ? 'odd' : 'even';
    newTR.removeClass('odd event').addClass(originalOddEvenClass);
    originalTR.replaceWith(newTR);
  },

  onAjaxUpdateRowCellError: function(rowId, columnId, errorText){
    var column = this.columnsById[columnId];
    var td = $(this.selectors.table).find('tbody tr[data-id={0}]'.format(rowId)).find('>td').eq(column.index);
    this.toggleCellSaving(td, false);

    var errorHtml = this.getTemplateTDContents('validation-error');
    errorHtml.find('div.original').append(td.html());
    errorHtml.find('.message .text').html(errorText);
    td.html(errorHtml);
    td.addClass('error');
  },

  onAjaxRowCreatingErrors: function(rowUID, errorHtml){
    var self = this;

    var tr = $(this.selectors.table).find('tbody tr.creating[data-row_uid={0}]'.format(rowUID));
    tr.addClass('error').find('td div.error').html(errorHtml);
    tr.find('td div.error .close').click(function(){
      self.removeCreatingRow(tr);
    });
    tr.find('td div.error form.loads_fancybox').submit(function(){
      $.fancybox.showActivity();
    });
  },

  onAjaxRowDestroyingErrors: function(rowId, errorHtml){
    var self = this;

    var tr = $(this.selectors.table).find('tbody tr.destroying[data-id={0}]'.format(rowId));
    tr.addClass('error').find('td .row_action_error').html(errorHtml);
    tr.find('td .row_action_error .close').click(function(){
      var originalTR = tr.find('td div.original tr');
      tr.replaceWith(originalTR);
    });
    this.toggleLoading(false);
  },

  onAjaxRowCreated: function(rowUID, rowId, newTableHtml){
    var tr = $(this.selectors.table).find('tbody tr.creating[data-row_uid={0}]'.format(rowUID));
    var newTR = newTableHtml.find('tbody tr[data-id={0}]'.format(rowId));
    tr.replaceWith(newTR);
  },

  onAjaxRowDestroyed: function(rowId){
    var self = this;
    var tr = $(this.selectors.table).find('tbody tr.destroying[data-id={0}]'.format(rowId));
    tr.fadeOut(function(){
      $(this).remove();
      self.toggleLoading(false);
    });
  },

  onDocumentMouseDown: function(e){
    var target = $(e.target);
    var grid = e.data.grid;
    if(grid.editing && target.closest('td.editing').length === 0){
      grid.commitEdit();
    }
  },

  onSelectionChanged: function(){
    //toggle multirow actions div
    $(this.selectors.grid).toggleClass('has_selection', this.hasSelectedRows());
    //update selected rows count
    $(this.selectors.multirow_actions).find('span.intro span.count').html(this.getSelectedRows().length);
  }

});

