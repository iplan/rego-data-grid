module AjaxDataGrid
  module ActionView
    module Helpers
      class TableRenderer
        def initialize(builder, template)
          @builder = builder
          @tpl = template
          @logger = Logging.logger[self.class]
        end

        def render_table
          @tpl.haml_tag :div, :'data-grid-id' => @builder.config.grid_id, :class => 'grid_table_wrapper' do
            table_layout do
              table_rows
            end
          end
        end

        def render_js
          columns = @builder.columns.collect{|c| c.js_options }
          @tpl.haml_concat @tpl.javascript_tag <<-js
            new $.datagrid.classes.DataGrid({
              i18n: $.parseJSON('#{I18n.t('plugins.data_grid.js').to_json}'),
              urls: #{@builder.table_options[:urls].to_json},
              columns: #{columns.to_json},
              reinit_qtip: #{@builder.table_options[:reinit_qtip]},
              reinit_fbox: #{@builder.table_options[:reinit_fbox]},
              server_params: $.parseJSON('#{@builder.config.server_params.to_json}')
            });
            jQuery(document).ready(function(){
              $.datagrid.helpers.findAPI('#{@builder.config.grid_id}').init();
            });
          js
        end

        private
        def table_layout
          @tpl.haml_tag :table, :class=>"grid_table #{@builder.config.model.rows.empty? ? 'empty' : ''}", :cellpadding => 0, :cellspacing => 0 do
            @tpl.haml_tag :thead do
              @tpl.haml_tag :tr do
                @builder.columns.each do |c|
                  next unless c.in_view?(@builder.config.active_view) # skip columns that are not in currently active grid view

                  header_cell_options = c.header_cell_options
                  if c.is_a?(SelectColumn) || c.is_a?(DestroyColumn)

                  else
                    if @builder.config.model.has_sort? && c.sort_by.to_s == @builder.config.model.sort_by
                      header_cell_options[:class] << " #{@builder.config.model.sort_direction}" # mark column as sorted
                      header_cell_options['data-sort-direction'] = (@builder.config.model.sort_direction == 'asc' ? 'desc' : 'asc') # change sort direction on next click
                    end
                  end
                  @tpl.haml_tag :th, header_cell_options do
                    @tpl.haml_tag :div, :class => 'cell' do
                      if c.is_a?(SelectColumn)
                        @tpl.haml_tag :span, :class => 'checkbox' << (@builder.config.model.options.selection == :all ? ' selected' : '')
                      else
                        @tpl.haml_tag :div, c.title, :class => 'maintitle' << (c.sub_title.blank? ? '' : ' with_subtitle')
                        @tpl.haml_tag :div, c.sub_title, :class => 'subtitle' unless c.sub_title.blank?
                      end
                      if c.qtip?
                        @tpl.haml_tag :div, c.options[:qtip], :class => 'tooltipContents'
                      end
                    end
                  end
                end
              end
            end
  
            @tpl.haml_tag :tbody do
              if @builder.config.model.any_rows?
                no_rows = @builder.config.model.rows.empty? ? ' filter-results' : ''
              else
                no_rows = ' rows'
              end
              @tpl.haml_tag :tr, :class => 'no-data' << no_rows do
                @tpl.haml_tag :td, :colspan => @builder.columns.size do
                  @tpl.haml_tag(:div, @builder.table_options[:empty_rows], :class => 'no rows')
                  @tpl.haml_concat no_rows_for_filter
                end
              end
              @tpl.haml_tag :tr, :class => 'template destroying' do
                @tpl.haml_tag :td, :colspan => @builder.columns.size do
                  @tpl.haml_tag :div, @tpl.raw(@builder.config.translate('template_row.destroy')), :class => 'message'
                  @tpl.haml_tag :div, '', :class => 'row_action_error'
                  @tpl.haml_tag :div, '', :class => 'original'
                end
              end
              @tpl.haml_tag :tr, :class => 'template creating' do
                @tpl.haml_tag :td, :colspan => @builder.columns.size do
                  @tpl.haml_tag :div, @tpl.raw(@builder.config.translate('template_row.create')), :class => 'message'
                  @tpl.haml_tag :div, :class => 'error' do
                    @tpl.haml_concat @tpl.raw(@builder.config.translate('template_row.create_error'))
                    @tpl.haml_tag :span, '', :class => 'error_message'
                    @tpl.haml_concat @tpl.link_to(I18n.t('application.close'), 'javascript:;', :class => 'close')
                  end
                end
              end
              @tpl.haml_tag :tr, :class => 'template cell_templates' do
                @tpl.haml_tag :td, :class => 'saving' do
                  @tpl.haml_tag :div, :class => 'saving' do
                    @tpl.haml_tag :span, :class => 'message' do
                      @tpl.haml_concat @tpl.image_tag('ajax_data_grid/spinner-16x16.gif')
                      @tpl.haml_tag :span, @builder.config.translate('saving'), :class => 'text'
                    end
                    @tpl.haml_tag :div, '', :class => 'original'
                  end
                end
                @tpl.haml_tag :td, :class => 'validation-error' do
                  @tpl.haml_tag :div, :class => 'validation-error' do
                    @tpl.haml_tag :div, :class => 'message' do
                      @tpl.haml_tag :span, '', :class => 'text'
                      @tpl.haml_concat @tpl.link_to('ok', 'javascript:;', :class => 'ok')
                    end
                    @tpl.haml_tag :div, '', :class => 'original'
                  end
                end
              end
              yield #render rows (invoked block that should call table_rows method)
            end  
          end
        end

        def table_rows
          @logger.info "------------------------------------- render_type = #{@builder.table_options[:render_type]}------------------------------------- "
          if @builder.table_options[:render_type] == :haml
            table_rows_haml
          elsif @builder.table_options[:render_type] == :string_plus
            table_rows_string_plus
          elsif @builder.table_options[:render_type] == :string_concat
            table_rows_string_concat
          end
        end

        def table_rows_string_plus
          @builder.config.model.rows.each do |entity|
            html = ""
            entity_selected_class = @builder.config.model.row_selected?(entity) ? "selected" : ''
            row_title = @builder.table_options[:row_title].present? ? "data-row_title='#{@builder.table_options[:row_title].call(entity).to_s}'" : ''
            html += "<tr class='row #{@tpl.cycle(:odd, :even)} #{entity_selected_class}' data-id='#{entity.id}' #{row_title}>"
            @builder.columns.each do |c|
              next unless c.in_view?(@builder.config.active_view) # skip columns that are not in currently active grid view

              cell_attributes = c.body_cell_options.update(body_cell_data_options(c, entity))

              html += "<td #{cell_attributes.collect{|k,v| "#{k}='#{v}'"}.join(' ')}>"
                html += "<div class='cell'>"
                  if c.is_a?(SelectColumn)
                    html += "<span class='checkbox #{entity_selected_class}'></span>"
                  elsif c.is_a?(EditColumn)
                    cell_content = extract_column_content(c, entity, false)
                    if cell_content.nil?
                      url = c.url
                      url = url.call(entity) if url.is_a?(Proc)
                      html += @tpl.link_to(@tpl.image_tag('/images/blank.gif'), url, c.link_to_options)
                    else
                      html += cell_content.to_s
                    end
                  elsif c.is_a?(DestroyColumn)
                    cell_content = extract_column_content(c, entity, false)
                    if cell_content.nil?
                      url = c.url
                      url = url.call(entity) if url.is_a?(Proc)
                      html += @tpl.link_to(@tpl.image_tag('/images/blank.gif'), url, c.link_to_options)
                    else
                      html += cell_content.to_s
                    end
                  else
                    cell_content = extract_column_content(c, entity).to_s
                    html += cell_content unless cell_content.nil?
                  end
                html += "</div>"
              html += "</td>"
            end
            html += "</tr>"

            @tpl.haml_concat html

          end
        end

        def table_rows_string_concat
          @builder.config.model.rows.each do |entity|
            html = ''
            entity_selected_class = @builder.config.model.row_selected?(entity) ? ' selected' : ''
            row_title = @builder.table_options[:row_title].present? ? 'data-row_title="' << @builder.table_options[:row_title].call(entity).to_s << '"' : ''
            html << '<tr class="row ' << @tpl.cycle(:odd, :even) << entity_selected_class << '" data-id="' << entity.id.to_s << '"' << row_title << '>'
            @builder.columns.each do |c|
              next unless c.in_view?(@builder.config.active_view) # skip columns that are not in currently active grid view

              cell_attributes = c.body_cell_options.update(body_cell_data_options(c, entity))

              html << '<td '
                cell_attributes.each{|k,v| html << k.to_s << '="' << Haml::Helpers.escape_once(v.to_s) << '" '}
              html << '>'
                html << '<div class="cell">'
                  if c.is_a?(SelectColumn)
                    html << '<span class="checkbox ' << entity_selected_class << '"></span>'
                  elsif c.is_a?(EditColumn)
                    cell_content = extract_column_content(c, entity, false)
                    if cell_content.nil?
                      url = c.url
                      url = url.call(entity) if url.is_a?(Proc)
                      html << @tpl.link_to(@tpl.image_tag('/images/blank.gif'), url, c.link_to_options)
                    else
                      html << cell_content.to_s
                    end
                  elsif c.is_a?(DestroyColumn)
                    cell_content = extract_column_content(c, entity, false)
                    if cell_content.nil?
                      url = c.url
                      url = url.call(entity) if url.is_a?(Proc)
                      html << @tpl.link_to(@tpl.image_tag('/images/blank.gif'), url, c.link_to_options)
                    else
                      html << cell_content.to_s
                    end
                  else
                    cell_content = extract_column_content(c, entity).to_s
                    html << cell_content unless cell_content.nil?
                  end
                html << '</div>'
              html << '</td>'
            end
            html += '</tr>'

            @tpl.haml_concat html

          end
        end

        def table_rows_haml
          @builder.config.model.rows.each do |entity|
            cls_selected = @builder.config.model.row_selected?(entity) ? ' selected' : ''
            cls = 'row ' << @tpl.cycle(:odd, :even) << cls_selected
            @tpl.haml_tag :tr, :class => cls, 'data-id' => entity.id, 'data-row_title' => @builder.table_options[:row_title].present? ? "data-row_title='#{@builder.table_options[:row_title].call(entity).to_s}'" : nil do

              @builder.columns.each do |c|
                next unless c.in_view?(@builder.config.active_view) # skip columns that are not in currently active grid view
                @tpl.haml_tag :td, c.body_cell_options.update(body_cell_data_options(c, entity)) do
                  @tpl.haml_tag :div, :class => 'cell' do
                    if c.is_a?(SelectColumn)
                      @tpl.haml_tag :span, :class => 'checkbox' << cls_selected
                    elsif c.is_a?(EditColumn)
                      cell_content = extract_column_content(c, entity, false)
                      if cell_content.nil?
                        url = c.url
                        url = url.call(entity) if url.is_a?(Proc)
                        @tpl.haml_concat @tpl.link_to(@tpl.image_tag('/images/blank.gif'), url, c.link_to_options)
                      else
                        @tpl.haml_concat cell_content.to_s
                      end
                    elsif c.is_a?(DestroyColumn)
                      cell_content = extract_column_content(c, entity, false)
                      if cell_content.nil?
                        url = c.url
                        url = url.call(entity) if url.is_a?(Proc)
                        @tpl.haml_concat @tpl.link_to(@tpl.image_tag('/images/blank.gif'), url, c.link_to_options)
                      else
                        @tpl.haml_concat cell_content.to_s
                      end
                    else
                      cell_content = extract_column_content(c, entity).to_s
                      @tpl.haml_concat cell_content unless cell_content.nil?
                    end
                 end
                end
              end
            end
          end
        end


        def extract_column_content(column, entity, throw_error = true)
          if column.block.present?
            value = nil
            buffer = @tpl.with_output_buffer { value = column.block.call(entity) }
            if string = buffer.presence || value and string.is_a?(String)
              ERB::Util.html_escape string
            end
            #column.block.call(entity)
            #nil # so it won't do @tpl.haml_concat
          elsif column.binding_path.present?
            extract_entity_value_from_binding_path(entity, column)
          else
            if throw_error
              raise ArgumentError.new("Either block or binding_path must be given for data_grid column: column #{column.title}")
            else
              nil
            end
          end
        end

        def body_cell_data_options(column, entity)
          data_options = {}
          column.data_attributes.each do |attribute, value_path|
            val = extract_entity_value(entity, column, value_path)
            val = URI.escape(val) if val.present? && val.is_a?(String) && column.escape_data_attributes.include?(value_path)
            data_options["data-#{attribute}"] = val
          end
          data_options
        end

        def extract_entity_value_from_binding_path(entity, column)
          raise ArgumentError.new("Binding path is nil for column #{column.title}") if column.binding_path.nil?

          extract_entity_value(entity, column, column.binding_path)
        end
        
        def extract_entity_value(entity, column, value_path)
          value = nil
          if value_path.is_a?(Symbol) || value_path.is_a?(String)
            raise ArgumentError.new("Entity #{entity.class} doesn't respond to #{value_path}") unless entity.respond_to?(value_path)
            value = entity.send(value_path)
          elsif value_path.is_a?(Proc)
            value = value_path.call(entity)
          else
            raise ArgumentError.new("Don't know how to extract value from value path #{value_path.inspect} for entity #{entity.inspect} ")
          end

          #parse value
          if value.is_a?(Float) || value.is_a?(BigDecimal)
            format = column.value_format.is_a?(String) ? column.value_format : AjaxDataGrid::Column.default_formats[:float]
            value = sprintf(format, value)
          elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
            value = value.to_s
          end
          value
        end
        
        def no_rows_for_filter
          @tpl.render 'ajax_data_grid/no_filter_results.html', :builder => @builder
        end
        
      end
    end
  end
end
