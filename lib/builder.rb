module DataGrid

  class Builder

    attr_reader :config, :columns, :table_options

    def initialize(config, table_options = {})
      @config = config
      @table_options = {:empty_rows => 'No rows exist', :empty_filter => 'No rows has been found for this filter'}.update(table_options)
      @columns = []
    end

    def column(title, options = {}, &block)
      @columns << DataTableColumn.new(title, options, &block)
    end

  end


  class DataTableColumn
    attr_reader :title, :options, :header_cell_options, :body_cell_options, :block

    def initialize(title, options = {}, &block)
      @title = title
      @options = {:html => {}}.update(options)

      parse_html_options

      @block = block_given? ? block : nil
    end

    def binding_path
      @options[:binding_path]
    end

    def order_by
      @options[:order_by] || @options[:binding]
    end

    private
    def parse_html_options
      header_styles = []
      body_styles = []
      html = options[:html]

      header_styles << "width: #{options[:width]}px" if options[:width].present?
      body_styles << "width: #{options[:width]}px" if options[:width].present?

      @header_cell_options = {:style => header_styles.empty? ? nil : header_styles.join(';') }
      @body_cell_optoins = {:style => body_styles.empty? ? nil : body_styles.join(';')}
    end
    
  end

end