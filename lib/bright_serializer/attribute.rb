# frozen_string_literal: true

require_relative 'entity/base'

module BrightSerializer
  class Attribute
    attr_reader :key, :block, :condition, :entity
    attr_accessor :transformed_key

    def initialize(key, condition, entity, &block)
      @key = key
      @condition = condition
      @block = block
      @entity = entity ? Entity::Base.new(entity) : nil
    end

    def serialize(object, params, sideloader)
      return unless object

      value =
        if @block
          if @block.arity.abs == 1
            object.instance_eval(&@block)
          else
            object.instance_exec(object, params, sideloader, &@block)
          end
        elsif object.is_a?(Hash)
          object.key?(key) ? object[key] : object[key.to_s]
        else
          object.send(key)
        end

      value.respond_to?(:serializable_hash) ? value.serializable_hash : value
    end

    def condition?(object, params)
      return true unless @condition

      @condition.call(object, params)
    end
  end
end
