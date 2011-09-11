module DataGrid
  module ActionView
    module Helpers

      def data_grid_rows_per_page(cfg)
        content_tag(:div, :class => "pageSize") do
          [
            content_tag(:span, cfg.translate('rows_per_page.show')),
            select_tag('paging_page_size', options_for_select(cfg.options.per_page_sizes, :selected => cfg.rows.per_page)),
            content_tag(:span, cfg.translate('rows_per_page.per_page'))
          ].inject{|result, tag| result << tag }
        end
      end

      def data_grid_pagination(cfg)
        content_tag(:div, :class => 'pages') do
          will_paginate(cfg.rows, :inner_window => 2, :outer_window => 0, :link_separator => '', :param_name => :paging_current_page)
        end
      end

      def data_grid_pagination_info(cfg)
        
        content_tag(:div, :class => 'pagesInfo') do
          page_entries_info(cfg.rows)
        end
      end

      def data_grid_table(config, options = {}, &block)

        options = {:id => "grid_#{Time.now.to_i + rand(100)}"}.update(options)

        builder = DataGrid::Builder.new(config, options)
        yield builder # user defines columns and their content

        content_tag :div, :id => builder.table_options[:id], :class => 'grid_table' do
          build_data_grid_table(builder)
        end

      end

      private
      def build_data_grid_table(builder)
        data_grid_table_layout(builder) do
          data_grid_rows(builder)
        end
      end
      
      def data_grid_table_layout(builder, &block)
        content_tag :table, :class=>"grid #{string_if 'empty', builder.config.rows.empty? }", :cellpadding => 0, :cellspacing => 0 do
          thead =
            content_tag :thead do
              content_tag :tr do
                builder.columns.collect do |c|
                  content_tag :th, c.header_cell_options do
                    c.title
                  end
                end.inject{|result, tag| result << tag }
              end
            end
        
          tbody =
            content_tag :tbody do
              nodata =
                content_tag :tr, :class => 'no-data' do
                  content_tag :td, :colspan => builder.columns.size do
                    content_tag(:div, builder.table_options[:empty_rows], :class => 'no-rows') <<
                    content_tag(:div, builder.table_options[:empty_filter], :class => 'no-filter-results')
                  end
                end

              rows = yield

              nodata << rows
            end

          thead << tbody
        end
      end

      def data_grid_rows(builder)
        builder.config.rows.collect do |entity|
          content_tag :tr, :class => cycle(:odd,:even), 'data-id' => entity.id do
            builder.columns.collect do |c|
              content_tag :td, c.body_cell_options do
                data_grid_extract_column_content(builder, c, entity)
              end
            end.inject{|result, tag| result << tag }
          end
        end.inject{|result, tag| result << tag }
      end

      def data_grid_extract_column_content(builder, column, entity)
        if column.block.present?
          column.block.call(entity)
        elsif column.binding_path.present?
          raise ArgumentError.new("Entity #{entity.class} doesn't respond to #{column.binding_path}") unless entity.respond_to?(column.binding_path)
          entity.send(column.binding_path)
        else
          raise ArgumentError.new("Either block or binding_path must be given for data_grid column: column #{column.title}")
        end
      end
      
    end
  end
end
