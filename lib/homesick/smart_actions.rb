# -*- encoding : utf-8 -*-
class Homesick
  # A collection of wrapper actions that intelligently obey certain options
  module SmartActions
    # Similar to say_status in Thor::Actions, but does nothing if the quiet
    # option is enabled.
    def smart_say_status(*args)
      say_status(*args) unless options[:quiet]
    end

    # Similar to system in Kernel, but does nothing if the pretend option is
    # enabled.
    def smart_system(*args)
      system(*args) unless options[:pretend]
    end
  end
end
