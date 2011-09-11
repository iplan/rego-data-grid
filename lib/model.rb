require "will_paginate"
require "will_paginate/array"
require "ostruct"
require "active_support/core_ext/module/delegation"
require "active_record"

module DataGrid
  class Model

    attr_reader :rows, :options

    def initialize(rows, options = {})
      options = {:sort_direction => :asc, :paging_current_page => 1}.update(options)

      [:sort_direction, :sort_by].each{|key| options[key] = options[key].to_s if options[key].is_a?(Symbol) }

      @options = OpenStruct.new(options)
      @rows = fetch_rows(rows)
    end

    def has_sort?
      options.sort_by.is_a?(String)
    end

    def has_paging?
      options.paging_page_size.is_a?(Integer)
    end

    def fetch_rows(rows)
      if has_sort?
        if rows.is_a?(ActiveRecord::Relation)
          rows = rows.order("#{options.sort_by} #{options.sort_direction}")
        elsif rows.is_a?(Array)
          sort_by = options.sort_by
          rows = rows.sort_by{|e| value = e.send(sort_by); (value.is_a?(String) ? value.downcase : value) }
          rows.reverse! if options.sort_direciton == 'desc'
        end
      end

      rows = rows.paginate(:page => options.paging_current_page, :per_page => options.paging_page_size) if has_paging?
      rows
    end
    
  end
end