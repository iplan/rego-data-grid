require 'action_view'

module AjaxDataGrid
  module ActionView
    module Helpers

      def data_grid_rows_per_page(cfg)
        haml_tag(:div, :'data-grid-id' => cfg.grid_id, :class => "pageSize") do
          haml_tag(:span, cfg.translate('rows_per_page.show'))
          haml_concat select_tag('paging_page_size', options_for_select(cfg.options.per_page_sizes, :selected => cfg.model.rows.per_page))
          haml_tag(:span, cfg.translate('rows_per_page.per_page'))
        end
      end

      def data_grid_pagination(cfg)
        haml_tag(:div, :'data-grid-id' => cfg.grid_id, :class => 'pages') do
          haml_concat will_paginate(cfg.model.rows, :inner_window => 1, :outer_window => 0, :link_separator => '', :param_name => :paging_current_page)
        end
      end

      def data_grid_pagination_info(cfg)
        haml_tag(:div, :'data-grid-id' => cfg.grid_id, :class => 'pagesInfo') do
          haml_concat page_entries_info(cfg.model.rows)
        end
      end

      def data_grid_table(cfg, options = {}, &block)
        options = {:generate_js => !request.xhr?}.update(options)

        builder = AjaxDataGrid::Builder.new(cfg, options)
        yield builder # user defines columns and their content

        renderer = TableRenderer.new(builder, self)
        renderer.render_table
        renderer.render_js if options[:generate_js]
      end

    end
  end
end


ActionView::Base.send :include, AjaxDataGrid::ActionView::Helpers