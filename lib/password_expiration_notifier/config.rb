require 'password_expiration_notifier'
require 'ostruct'
require 'yaml'

module PasswordExpirationNotifier
  class Config < OpenStruct
    def initialize(options = nil)
      @table = {}
      @hash_table = {}

      if options
        if options[:config]
          conf = YAML.load_file(options[:config])
          @table, @hash_table = load_config(conf)
        end

        @table, @hash_table = load_config(options, @table, @hash_table)
      end
    end

    def to_h
      @hash_table
    end

    private
    def load_config(conf, table = {}, hash_table = {})
      table = table.dup
      hash_table = hash_table.dup
      conf.each do |k,v|
        table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
        hash_table[k.to_sym] = v

        new_ostruct_member(k)
      end
      [table, hash_table]
    end
  end
end
