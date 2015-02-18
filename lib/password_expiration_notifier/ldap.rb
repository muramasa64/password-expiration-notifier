require 'password_expiration_notifier'
require 'net/ldap'

module PasswordExpirationNotifier
  class ActiveDirectory
    def initialize(options = {})
      opt = options.dup
      opt[:auth] = {
        username: options[:user],
        password: options[:password],
        method:   :simple
      }
      @filters = []
      @connection = Net::LDAP.new(opt)
    end

    def add_filter(key = nil, value = nil)
      @filters << Net::LDAP::Filter.eq(key, value)
    end

    def users(key = nil, value = nil)
      users = {}
      if @connection.bind
        filter = @filters.inject {|f1, f2| f1 & f2}
        @connection.search(filter: filter, return_result: false) do |entry|
          entries = {}
          entry.each do |attr, values|
            entries[attr] = values.size == 1 ? values.first : values
          end
          users[entry['sAMAccountName'].first] = entries
        end
      end
      users.map do |k,v|
        v[:pwdlastset] = ActiveDirectory.windows_time_to_ruby_time(v[:pwdlastset])
        [k, v]
      end
    end

    class << self
      def windows_time_to_ruby_time(windows_time)
        unix_time = (windows_time.to_i)/10000000-11644473600
        Time.at(unix_time)
      end
    end
  end
end
