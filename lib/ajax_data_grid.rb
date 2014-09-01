#%w{config   model   builder   helpers   response_helpers   table_renderer  engine}.each do |file_name|
#  require File.join(File.dirname(__FILE__), 'ajax_data_grid', file_name)
#end

#module AjaxDataGrid
#
#end
require 'ajax_data_grid/config'
require 'ajax_data_grid/model'
require 'ajax_data_grid/table_builder'
require 'ajax_data_grid/toolbar_builder'
require 'ajax_data_grid/helpers'
require 'ajax_data_grid/response_helpers'
require 'ajax_data_grid/table_renderer'

require 'ajax_data_grid/rails_engine' if defined?(Rails)
