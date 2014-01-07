# -*- encoding : utf-8 -*-
class Homesick
  # A collection of wrapper actions that intelligently obey certain options
  module SmartActions
    # Similar to say_status in Thor::Actions, but does nothing if the quiet
    # option is enabled.
    def smart_say_status(*args)
      say_status(*args) unless options[:quiet]
    end
  end
end
