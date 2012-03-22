# DataGrid
#puts "load #{__FILE__}"

%w{config   model   builder   helpers   response_helpers   table_renderer}.each do |file_name|
  require_dependency File.join(File.dirname(__FILE__), 'ajax_data_grid', file_name)
end

module AjaxDataGrid

end
