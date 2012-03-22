module AjaxDataGrid

  class Config
    @@server_params_keys_reject = [:i18n_scope, :per_page_sizes, :row_title, :selection, :any_rows, :sql_sorters]
    @@model_options_keys_reject = [:i18n_scope, :per_page_sizes, :row_title]

    attr_reader :model, :options, :server_params

    def initialize(options = {})
      # defaults
      options = {
        :grid_id => "grid_#{Time.now.to_i + rand(100)}",
        :any_rows => true,
        :i18n_scope => 'plugins.data_grid',
        :per_page_sizes => [10, 25, 50, 1000],
        :paging_current_page => 1,
        :selection => :none, #if rows should render preselected
        :sort_by => :created_at,
        :sort_direction => 'desc'
      }.update(options)

      # update from params
      params = options.delete(:params)
      options = self.update_from_params(params, options) if params.present?

      rows = options.delete(:rows)

      @options = OpenStruct.new(options)
      init_model(rows) if rows.present?
    end

    def update_from_params(params, options)
      #update options params
      options.keys.each do |key|
        value = params[key]
        options[key] = value unless value.nil?
      end

      # type conversion
      [:paging_page_size, :paging_current_page].each{|key| options[key] = options[key].to_i if options[key].present? }
      
      options
    end

    def init_model(filtered_rows)
      @server_params = options.marshal_dump.except(*@@server_params_keys_reject)
      @model_options = options.marshal_dump.except(*@@model_options_keys_reject)

      @model = Model.new(filtered_rows, @model_options)
      @model.rows
    end

    #def initialize(rows, options = {})
    #  options = {
    #    :id => "grid_#{Time.now.to_i + rand(100)}",
    #    :any_rows => true,
    #    :i18n_scope => 'plugins.data_grid',
    #    :per_page_sizes => [10, 25, 50, 1000],
    #    :selection => :none
    #  }.update(options)
    #  options[:grid_id] = options.delete(:id)
    #
    #  model_options = options.reject{|k,v| [:i18n_scope, :per_page_sizes].include?(k) }
    #
    #  @options = OpenStruct.new(options)
    #  @model = Model.new(rows, model_options)
    #end

    def grid_id
      @options.grid_id
    end

    def translate(key)
      I18n.t(key, :scope => @options.i18n_scope)
    end

  end

end
