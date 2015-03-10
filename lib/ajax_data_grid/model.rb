require "will_paginate"
require "will_paginate/array"
require "ostruct"
require "active_support/core_ext/module/delegation"
require "active_record"

module AjaxDataGrid
  class Model

    attr_reader :rows, :options

    def initialize(rows, options = {})
      @logger = Logging.logger[self.class]

      options = {:sort_direction => :asc, :paging_current_page => 1, :sql_sorters => {}, :array_sorters => {}}.update(options)

      [:sort_direction, :sort_by].each{|key| options[key] = options[key].to_s if options[key].is_a?(Symbol) }

      @options = OpenStruct.new(options)
      @rows = fetch_rows(rows)
    end

    def any_rows?
      @options.any_rows
    end

    def has_sort?
      @options.sort_by.is_a?(String)
    end

    def sort_by
      @options.sort_by
    end

    def sort_direction
      @options.sort_direction
    end

    def has_paging?
      @options.paging_page_size.is_a?(Integer)
    end

    def row_selected?(row)
      if @options.selection == :all
        true
      elsif @options.selection == :none
        false
      elsif @options.selection.is_a? Proc
        @options.selection.call(row)
      end
    end

    def fetch_rows(rows)
      rows = rows.scoped if rows.respond_to?(:scoped)

      @logger.debug "-----------------------------------data grid model rows are #{rows.class}"

      # peform sorting
      if has_sort?
        sort_by = @options.sort_by
        if rows.is_a?(ActiveRecord::Relation)
          if @options.sql_sorters.has_key?(sort_by.to_sym)
            sort_by = @options.sql_sorters[sort_by.to_sym]
          elsif rows.column_names.include?(sort_by)
            sort_by = "#{rows.table_name}.#{sort_by}" unless sort_by.include?('.')
          else
            raise ArgumentError.new("Sorting by #{sort_by} is not supported")
          end

          if sort_by.is_a?(Hash) # choose sort string with direction (complex multiple cols sorting) - sort_by = {:asc => 'col1 asc, col2 desc', :desc => 'col1 desc, cols asc'}
            sort_by_with_direction = sort_by[@options.sort_direction.to_sym]
          else  # add direction (simple one col sorting)
            sort_by_with_direction = "#{sort_by} #{@options.sort_direction}"
          end
          rows = rows.reorder(sort_by_with_direction)
        elsif rows.is_a?(Array)
          if @options.array_sorters.has_key?(sort_by.to_sym)
            sort_proc = @options.array_sorters[sort_by.to_sym]
          else
            sort_proc = Proc.new do |a,b|
              va = a.send(sort_by)
              vb = b.send(sort_by)
              va = va.downcase if va.is_a?(String)
              vb = vb.downcase if vb.is_a?(String)
              va <=> vb
            end
          end
          direction_multiply = @options.sort_direction == 'desc' ? -1 : 1
          rows = rows.sort{|a,b| sort_proc.call(a,b) * direction_multiply }
        end
      end

      # perform pagination
      if has_paging?
        rows = rows.paginate(:page => options.paging_current_page, :per_page => options.paging_page_size)
        if rows.empty? && any_rows?
          options.paging_current_page = 1
          rows = rows.paginate(:page => 1, :per_page => options.paging_page_size)
        end
      end

      rows
    end

  end
end