require 'password_expiration_notifier'
require 'net/ldap'

module PasswordExpirationNotifier
  class LDAP
    def initialize(conf)
      opt = conf.ldap.to_h
      opt[:auth] = {
        username: conf.ldap.user,
        password: conf.ldap.password,
        method:   :simple
      }
      @filters = []
      @connection = Net::LDAP.new(opt)
    end

    def add_filter(key, value)
      @filters << Net::LDAP::Filter.eq(key, value)
    end

    def users(key = nil, value = nil)
      users = {}
      if @connection.bind
        filter = @filters.inject {|f1, f2| f1 & f2}
        @connection.search(filter: filter, return_result: false) do |entry|
          # UserAccountControl flag 0x0002 => ACCOUNTDISABLE
          # see https://support.microsoft.com/en-us/kb/305144
          next unless entry['UserAccountControl'].first.to_i & 0x0002 == 0
          entries = {}
          entry.each do |attr, values|
            entries[attr] = values.size == 1 ? values.first : values
          end
          users[entry['sAMAccountName'].first] = entries
        end
      end
      users.map do |k,v|
        v[:pwdlastset] = LDAP.windows_time_to_ruby_time(v[:pwdlastset])
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

