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

      def data_grid_toolbar(cfg, options = {}, &block)
        options = {:pos => :top}.update(options)
        builder = AjaxDataGrid::ToolbarBuilder.new
        yield builder if block.present? # user defines multirow actionsn and side controls
        haml_tag 'div.toolbar', :class => options[:pos] do
          haml_tag 'div', cfg.translate('loading'), 'data-state'=>:loading
          haml_tag 'div', 'data-state'=>:normal do
            haml_tag 'div.right_wrapper'do
              if cfg.options.views.size > 1
                data_grid_active_view(cfg)
              end
              if builder.side_controls_block.present?
                haml_tag 'div.side-controls' do
                  haml_concat capture(&builder.side_controls_block)
                end
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
          end
          if builder.multirow_actions_block.present?
            haml_tag 'div', 'data-state'=>:multirow_actions, 'data-grid-id' => cfg.grid_id do
              haml_tag 'span.intro', raw(cfg.translate('multirow_actions.intro', :count => '<span class="count">0</span>'))
              haml_concat capture(&builder.multirow_actions_block)
              haml_concat link_to(cfg.translate('multirow_actions.close'), 'javascript:;', :class => 'btn close_multirow_actions', 'data-action'=>:close)
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

        builder = AjaxDataGrid::TableBuilder.new(cfg, options)
        yield builder # user defines columns and their content

        TableRenderer.new(builder, self).render_all
        #renderer.render_js if options[:generate_js]
      end

    end
  end
end

#ActionView::Base.send :include, AjaxDataGrid::ActionView::Helpers