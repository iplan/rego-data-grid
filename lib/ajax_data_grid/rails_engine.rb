require 'rails/engine'

module AjaxDataGrid
  class Railtie < Rails::Engine
    initializer "ajax_data_grid.helpers" do |app|
      ::ActionView::Base.send(:include, AjaxDataGrid::ActionView::Helpers)
      ::ActionView::Base.send(:include, AjaxDataGrid::ActionView::ResponseHelpers)
    end
  end
end
