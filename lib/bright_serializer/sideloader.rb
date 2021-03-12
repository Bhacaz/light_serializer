# frozen_string_literal: true

module BrightSerializer
  class Sideloader
    def initialize(loaders, objects)
      @loaders = loaders
      @objects = objects
      @loaded = {}
    end

    def method_missing(method_name)
      return super unless @loaders.key?(method_name)

      @loaded[method_name] ||= @loaders[method_name].call(@objects)
    end

    def respond_to_missing?(method_name, include_private = false)
      @loaders.key?(method_name) || super
    end
  end
end