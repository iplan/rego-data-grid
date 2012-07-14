module AjaxDataGrid
  module ActionView
    module Helpers

      def data_grid_active_view(cfg)
        haml_tag 'div.activeView', 'data-grid-id' => cfg.grid_id do
          haml_tag :span, cfg.translate('views.active_view')
          haml_concat select_tag('active_view', options_for_select(cfg.options.views, :selected => cfg.active_view))
        end
      end

      def data_grid_rows_per_page(cfg)
        haml_tag 'div.pageSize', 'data-grid-id' => cfg.grid_id do
          haml_tag :span, cfg.translate('rows_per_page.show')
          haml_concat select_tag('paging_page_size', options_for_select(cfg.options.per_page_sizes, :selected => cfg.model.rows.per_page))
          haml_tag :span, cfg.translate('rows_per_page.per_page')
        end
      end

      def data_grid_pagination(cfg)
        haml_tag 'div.pages', 'data-grid-id' => cfg.grid_id do
          haml_concat will_paginate(cfg.model.rows, :inner_window => 1, :outer_window => 0, :link_separator => '', :param_name => :paging_current_page)
        end
      end

      def data_grid_pagination_info(cfg)
        haml_tag 'div.pagesInfo', 'data-grid-id' => cfg.grid_id do
          haml_concat page_entries_info(cfg.model.rows)
        end
      end

      def data_grid_toolbar(cfg, options = {})
        options = {:pos => :top}.update(options)
        haml_tag 'div.toolbar', :class => options[:pos] do
          haml_tag 'div.right_wrapper'do
            haml_tag 'div.loading', cfg.translate('loading')
            if cfg.options.views.size > 1
              data_grid_active_view(cfg)
            end
          end
          if cfg.model.has_paging?
            haml_tag 'div.pagination_wrapper' do
              data_grid_rows_per_page(cfg)
              data_grid_pagination(cfg)
              data_grid_pagination_info(cfg)
              #haml_tag 'div.clear'
            end
          end
          if options[:multirow_actions].is_a?(Array) && options[:multirow_actions].length > 0
            haml_tag 'div.multirow_actions', 'data-grid-id' => cfg.grid_id do
              haml_tag 'span.intro', raw(cfg.translate('multirow_actions.intro', :count => '<span class="count">0</span>'))
              options[:multirow_actions].each do |link|
                haml_concat link
              end
              haml_concat link_to(cfg.translate('multirow_actions.close'), 'javascript:;', :class => 'button3 grey close')
            end
          end
          #haml_tag 'div.clear'
        end
      end

      def data_grid_table(cfg, options = {}, &block)
        options = {
          :render_init_json => !request.xhr?,
          :render_javascript_tag => !request.xhr?
        }.update(options)

        builder = AjaxDataGrid::Builder.new(cfg, options)
        yield builder # user defines columns and their content

        TableRenderer.new(builder, self).render_all
        #renderer.render_js if options[:generate_js]
      end

    end
  end
end

#ActionView::Base.send :include, AjaxDataGrid::ActionView::Helpers