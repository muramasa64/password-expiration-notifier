require 'password_expiration_notifier'
require 'slack-notify'

module PasswordExpirationNotifier
  class Slack
    def initialize(conf)
      @conf = conf
    end

    def notify_to(user)
      attr = user.last
      client = SlackNotify::Client.new(
        webhook_url: @conf.slack.webhook_url,
        channel: "@#{attr[:samaccountname]}",
        icon_url: @conf.slack.icon_url,
        icon_emoji: @conf.slack.icon_emoji,
        link_names: @conf.slack.link_names
      )
      message = "Your domain account #{attr[:samaccountname]}'s password expire at #{attr[:expire_at]}. Please update your password."
      unless @conf.dry_run
        client.notify(message)
      end
      return message
    end
  end
end
