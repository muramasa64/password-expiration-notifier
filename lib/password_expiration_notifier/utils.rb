require 'password_expiration_notifier'
require 'password_expiration_notifier/ldap'
require 'password_expiration_notifier/config'
require 'date'

module PasswordExpirationNotifier
  module Utils

    def now
      @now ||= Time.now
    end

    def remaining(password_last_set_t, expiration_days)
      -((now - password_last_set_t).divmod(24*60*60)[0] - expiration_days)
    end

    def expire_at(password_last_set_t, expiration_days)
      password_last_set_t + (24 * 60 * 60 * expiration_days)
    end

    def expire_soon?(remaining, expire_within)
      remaining <= 0 || remaining <= expire_within
    end

    def expired?(remaining, expire_within)
      remaining <= 0 || remaining > expire_within
    end

    def show_list(users)
      puts "username\tdescription\texpire_at\tremaining"
      users.sort_by {|user| user[1][:remaining] }.each do |user|
        attr = user[1]
        puts "#{attr[:samaccountname]}\t#{attr[:description]}\t#{attr[:expire_at]}\t#{attr[:remaining]}"
      end
    end

    def select(attr, conf)
      if options[:all]
        attr
      else
        if conf.exclude_expired && !expired?(attr[:remaining], conf.expire_within)
          attr
        end
        if expire_soon?(attr[:remaining], conf.expire_within)
        end
      end

    end

    def fetch_users(conf)
      ad = PasswordExpirationNotifier::LDAP.new(conf)
      ad.add_filter('objectClass', 'user')
      if conf.ldap.filterkey && conf.ldap.filtervalue
        ad.add_filter(conf.ldap.filterkey, conf.ldap.filtervalue)
      end

      selected_users = {}
      ad.users.each do |user, attr|
        attr[:remaining] = remaining(attr[:pwdlastset], conf.expiration_days)
        attr[:expire_at] = expire_at(attr[:pwdlastset], conf.expiration_days)
        if options[:all] || expire_soon?(attr[:remaining], conf.expire_within)
          next if conf.exclude_expired && attr[:remaining] <= 0
          selected_users[user] = attr
        end
      end
      selected_users
    end

    def config(options)
      PasswordExpirationNotifier::Config.new(options)
    end
  end
end
