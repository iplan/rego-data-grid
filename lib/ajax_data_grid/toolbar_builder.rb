module AjaxDataGrid

  class ToolbarBuilder

    attr_reader :multirow_actions_block, :side_controls_block

    def initialize
    end

    def multirow_actions(&block)
      @multirow_actions_block = block
    end

    def side_controls(&block)
      @side_controls_block = block
    end

  end

end