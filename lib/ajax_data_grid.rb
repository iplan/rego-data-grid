%w{config   model   builder   helpers   response_helpers   table_renderer  engine}.each do |file_name|
  require File.join(File.dirname(__FILE__), 'ajax_data_grid', file_name)
end

module AjaxDataGrid

end
