module DataGrid

  class Config
    attr_reader :model, :options

    def initialize(rows, options = {})
      options = {
        :i18n_scope => 'plugins.data_grid',
        :per_page_sizes => [10, 50, 100, 200, 400],
      }.update(options)

      model_options = options.reject{|k,v| [:i18n_scope, :per_page_sizes].include?(k) }

      @options = OpenStruct.new(options)
      @model = Model.new(rows, model_options)
    end

    def translate(key)
      I18n.t(key, :scope => @options.i18n_scope)
    end
  end

end
