require 'password_expiration_notifier'
require 'password_expiration_notifier/utils'
require 'thor'

module PasswordExpirationNotifier
  class CLI < Thor
    include Utils
    class_option :config, aliases: [:c], type: :string,  desc: "use config file", default: "notifier.config"
    class_option :debug,                 type: :boolean, desc: "debug mode"

    desc "list [--all] [--expire-within=DAYS]", "show account list of Active Directory"
    option :all,             aliases: [:a], type: :boolean, desc: "show all accounts"
    option :expire_within,   aliases: [:e], type: :numeric, desc: "expire within n days", default: 7
    option :expiration_days, aliases: [:d], type: :numeric, desc: "password expiration days", default: 90
    def list()
      users = fetch_users(config(options))
      show_list(users)
    end

    desc "notify [--expire-within=DAYS] [--dry-run]", "send notify mail to the account it expires"
    option :expire_within,   aliases: [:e], type: :numeric, desc: "expire within n days", default: 7
    option :expiration_days, aliases: [:d], type: :numeric, desc: "password expiration days", default: 90
    option :dry_run,                        type: :boolean, desc: "show list only. do not sent notify"
    def notify()
      conf = config(options)
      users = fetch_users(conf)
      slack = PasswordExpirationNotifier::Slack.new(conf)
      users.each do |user|
        slack.notify_to(user)
      end
    end
  end
end
