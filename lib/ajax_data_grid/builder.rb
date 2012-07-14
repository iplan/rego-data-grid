module AjaxDataGrid

  class Builder

    attr_reader :config, :tile_config, :columns, :table_options

    def initialize(config, table_options = {})
      @config = config
      @table_options = {:reinit_qtip => true, :reinit_fbox => true, :manual_clear_filter => false, :empty_rows => config.translate('no_rows.message'), :empty_filter => config.translate('no_rows_filter.message'), :render_type => :string_concat}.update(table_options)
      raise ArgumentError.new(":row_title attribute not specified or not a Proc") if @table_options[:row_title].present? && !@table_options[:row_title].is_a?(Proc)
      @columns = []
      @tile = nil
    end

    def tile(options = {}, &block)
      raise ArgumentError.new("Must pass a block") unless block_given?
      @tile_config = TileConfig.new(options, &block)
    end

    def column(title, options = {}, &block)
      add_column(Column, title, options, &block)
    end

    def select_column
      add_column(SelectColumn, '', :class => 'selection')
    end

    def edit_column(options = {}, &block)
      options = {:width => 50}.update(options.update(:class => 'edit'))
      raise ArgumentError.new("Must specify url attribute for edit column (:url => ..)") if options[:url].blank?
      add_column(EditColumn, options[:title] || '', options, &block)
    end

    def destroy_column(options = {}, &block)
      options = {:width => 50,
                 :button_tooltip => @config.translate('destroy_column.tooltip'),
                 :url_method => :delete,
                 :url_remote => true,
                 :confirm_message => @config.translate('destroy_column.confirm_message')
                }.update(options.update(:class => 'destroy'))
      raise ArgumentError.new("Must specify url attribute for destroy column (:url => ..)") if options[:url].blank?
      add_column(DestroyColumn, options[:title] || '', options, &block)
    end

    private
    def add_column(clazz, title, options, &block)
      @columns << clazz.new(title, options.update(:index => @columns.length), &block)
    end

  end

  class TileConfig
    attr_reader :block
    def initialize(options, &block)
      @block = block
    end
  end

  class Column
    attr_reader :title, :options, :header_cell_options, :body_cell_options, :js_options, :block

    @@default_formats = {
      :float => '%.2f' # will be passed to sprintf
    }
    def self.default_formats; @@default_formats; end

    def initialize(title, options = {}, &block)
      @title = title
      @options = {:id => "column_#{options[:index]}", :html => {}}.update(options)

      @block = block_given? ? block : nil


      init_options
      init_html_options
      init_js_options
    end

    def id
      @options[:id]
    end

    def sub_title
      @options[:sub_title]
    end

    def binding_path
      @options[:binding_path]
    end

    def value_format
      @options[:format]
    end

    def sortable?
      @options[:sortable]
    end

    def sort_by
      @options[:sort_by]
    end

    def sort_direction
      @options[:sort_direction]
    end

    def editable?
      @options[:editable]
    end

    def data_attributes
      @options[:data_attributes]
    end

    def escape_data_attributes
      @options[:escape_data_attributes]
    end

    # array of grid views this columns belongs to. if nil, column belongs to all views
    def views
      @options[:views]
    end

    def in_view?(view)
      views.present? ? views.include?(view.to_sym) : true
    end

    def qtip?
      !options[:qtip].blank?
    end

    private
    def init_options
      opts = @options
      opts[:data_attributes] = opts[:data_attributes] || {}
      opts[:escape_data_attributes] = opts[:escape_data_attributes] || {}

      opts[:editable] = opts[:editor] if opts[:editable].blank?

      #if opts[:editor] && !opts[:binding_path].blank?
      #  opts[:editor][:value_path] = opts[:binding_path] if opts[:editor][:value_path].blank?
      #  opts[:editor][:update_path] = opts[:binding_path] if opts[:editor][:update_path].blank?
      #end

      if opts[:data_attributes].is_a?(Array)
        opts[:data_attributes] = opts[:data_attributes].inject({}){|h, item| h[item] = item; h }
      end

      if !opts[:binding_path].blank? && opts[:data_attributes][opts[:binding_path]].blank?
        opts[:data_attributes][opts[:binding_path]] = opts[:binding_path]
      end

      if editable?
        opts[:refresh_cols_indices] ||= []
        opts[:refresh_cols_indices] << options[:index] unless opts[:refresh_cols_indices].include?(options[:index])
      end
      
      #if editable? && opts[:data_attributes][opts[:editor][:value_path]].blank?
      #  opts[:data_attributes][opts[:editor][:value_path]] = opts[:editor][:value_path]
      #end

      if sortable?
        opts[:sort_by] = binding_path if opts[:sort_by].blank?
        opts[:sort_direction] = 'asc' if opts[:sort_direction].blank?
      end

      opts[:views] = [opts[:views]] if opts[:views].present? && !opts[:views].is_a?(Array)
    end
    
    def init_html_options
      @header_cell_options = {'data-column_id' => @id}
      @body_cell_options = {}
      header_styles = []
      body_styles = []
      header_classes = []
      body_classes = []

      html = options[:html]

      header_styles << "width: #{options[:width]}px" if options[:width].present?
      body_styles << "width: #{options[:width]}px" if options[:width].present?

      if options[:class]
        header_classes << options[:class]
        body_classes << options[:class]
      end

      if editable?
        body_classes << 'editable'
        body_classes << 'dialog_editor' if options[:editor] && options[:editor][:dialog]
        body_classes << 'fbox_editor' if options[:editor] && options[:editor][:fbox]
      end

      if sortable?
        header_classes << 'sortable'
        @header_cell_options['data-sort-by'] = sort_by
        @header_cell_options['data-sort-direction'] = sort_direction
      end

      if qtip?
        header_classes << 'tooltipTarget pos-bc-tc'
      end

      @header_cell_options[:style] = header_styles.join(';') if header_styles.size > 0
      @body_cell_options[:style] = body_styles.join(';') if body_styles.size > 0

      @body_cell_options[:class] = body_classes.join(' ') if body_classes.size > 0
      @header_cell_options[:class] = header_classes.join(' ') if header_classes.size > 0
    end

    def init_js_options
      @js_options = {}
      [:id, :binding_path, :editor, :index, :jq_dialog_confirm].each{|key| @js_options[key] = @options[key] if @options.has_key?(key) }
    end
  end

  class SelectColumn < Column

    def selection
      @options[:selection]
    end
  end

  class EditColumn < Column

    def url
      options[:url]
    end

    def link_to_options
      opts = {}
      opts[:class] = self.options[:url_class] if self.options[:url_class].present?
      opts
    end

  end

  class DestroyColumn < Column

    def button_tooltip
      options[:button_tooltip]
    end

    def url
      options[:url]
    end

    def url_method
      options[:url_method]
    end

    def url_remote
      #options[:url_remote]
      true #non remote urls not supported for now
    end

    def jq_dialog_confirm?
      options[:jq_dialog_confirm] == true
    end

    def confirm?
      !confirm_message.blank?
    end

    def confirm_message
      options[:confirm_message]
    end

    def link_to_options
      opts = {'ajax_method' => url_method, :title => button_tooltip}
      opts['data-confirm_message'] = self.confirm_message if self.confirm?
      if self.url_remote
        opts['data-ajax_submit'] = true
      end
      opts
    end


  end
end