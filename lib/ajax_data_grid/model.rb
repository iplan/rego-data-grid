require "will_paginate"
require "will_paginate/array"
require "ostruct"
require "active_support/core_ext/module/delegation"
require "active_record"

module AjaxDataGrid
  class Model

    attr_reader :rows, :options

    def initialize(rows, options = {})
      @logger = ActiveRecord::Base.logger

      options = {:sort_direction => :asc, :paging_current_page => 1, :sql_sorters => {}}.update(options)

      [:sort_direction, :sort_by].each{|key| options[key] = options[key].to_s if options[key].is_a?(Symbol) }

      @options = OpenStruct.new(options)
      @rows = fetch_rows(rows)
    end

    def any_rows?
      @options.any_rows
    end

    def has_sort?
      options.sort_by.is_a?(String)
    end

    def sort_by
      options.sort_by
    end

    def sort_direction
      options.sort_direction
    end

    def has_paging?
      options.paging_page_size.is_a?(Integer)
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

      @logger.info "-----------------------------------data grid model rows are #{rows.class}"

      # peform sorting
      if has_sort?
        if rows.is_a?(ActiveRecord::Relation)
          if @options.sql_sorters.has_key?(options.sort_by.to_sym)
            sort_by = @options.sql_sorters[options.sort_by.to_sym]
          elsif rows.column_names.include?(options.sort_by)
            sort_by = options.sort_by
            sort_by = "#{rows.table_name}.#{sort_by}" unless sort_by.include?('.')
          else
            raise ArgumentError.new("Sorting by #{options.sort_by} is not supported")
          end

          rows = rows.reorder("#{sort_by} #{options.sort_direction}")
        elsif rows.is_a?(Array)
          sort_by = options.sort_by
          rows = rows.sort_by{|e| value = e.send(sort_by); (value.is_a?(String) ? value.downcase : value) }
          rows.reverse! if options.sort_direciton == 'desc'
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