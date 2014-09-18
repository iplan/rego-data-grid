module AjaxDataGrid
  module ActionView
    module ResponseHelpers

      def data_grid_ajax_row_destroy_error(model, options = {})
        options = {:row_title => t('plugins.data_grid.row')}.update(options)
        message = t('plugins.data_grid.template_row.destroy_error', :row_title => options[:row_title]) << ':'
        render 'ajax_data_grid/table_row_destroy_error.html', :options => options, :model => model, :message => message
      end

      def data_grid_ajax_api_response_js(dgc, options = {})
        render 'ajax_data_grid/grid_api.js', :dgc => dgc, :grid_partial => options[:partial] || 'grid.html'
      end

    end
  end
end

#ActionView::Base.send :include, AjaxDataGrid::ActionView::ResponseHelpers