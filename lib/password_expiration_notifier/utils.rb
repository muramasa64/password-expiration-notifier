require 'password_expiration_notifier'
require 'password_expiration_notifier/ldap'
require 'date'

module PasswordExpirationNotifier
  module Utils

    def now
      @now ||= Time.now
    end

    def remaining(password_last_set_t, expiration_days)
      -((now - password_last_set_t).divmod(24*60*60)[0] - expiration_days)
    end

    def expire_soon?(remaining, expiration_days, expire_within)
      remaining <= 0 || remaining <= expire_within
    end

    def show_list(users)
      puts "username\tdescription\tpassword_last_changed\tremaining"
      users.sort_by {|user| user[1][:remaining] }.each do |user|
        attr = user[1]
        puts "#{attr[:samaccountname]}\t#{attr[:description]}\t#{attr[:pwdlastset]}\t#{attr[:remaining]}"
      end
    end

    def fetch_users(options)
      ad = PasswordExpirationNotifier::ActiveDirectory.new(options)
      ad.add_filter('objectClass', 'user')
      if options[:filterkey] && options[:filtervalue]
        ad.add_filter(options[:filterkey], options[:filtervalue])
      end

      selected_users = {}
      ad.users.each do |user, attr|
        attr[:remaining] = remaining(attr[:pwdlastset], options[:expiration_days])
        if options[:all] || expire_soon?(attr[:remaining], options[:expire_within], options[:expire_within])
          selected_users[user] = attr
        end
      end
      selected_users
    end
  end
end
