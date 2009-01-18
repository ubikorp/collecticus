class StatusNotifier < ActionMailer::Base
  @@sender_address = %("Application Status" <status@collectic.us>)
  cattr_accessor :sender_address

  @@status_recipients = %(support@nthmetal.com)
  cattr_accessor :status_recipients
  
  @@email_prefix = "[collectic.us] "
  cattr_accessor :email_prefix

  def releases_update_email(log)
    recipients status_recipients
    from       sender_address
    subject    "Release Data Updated #{Time.now.strftime("%m-%d-%y")}"
    body       :status => log
  end
end
