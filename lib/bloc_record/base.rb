require 'bloc_record/utility'
require 'bloc_record/schema'
require 'bloc_record/persistence'
require 'bloc_record/selection'
require 'bloc_record/connection'
require 'bloc_record/collection'
require 'bloc_record/associations'

module BlocRecord
  class Base
    include Persistence
    extend Selection
    extend Schema
    extend Connection
    extend Associations

    def initialize(columns={})
      columns = BlocRecord::Utility.convert_keys(columns)

      columns.each do |col, val|
        public_send "#{col}=", val
        # self.instance_variable_set("@#{col}", options[col])
      end
    end

    def self.inherited(model)
      model.columns.each do |col|
        model.send(:attr_accessor, col)
      end
    end
  end
end
