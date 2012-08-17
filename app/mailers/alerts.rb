##
# Mailer methods can be defined using the simple format:
#
# email :registration_email do |name, user|
#   from 'admin@site.com'
#   to   user.email
#   subject 'Welcome to the site!'
#   locals  :name => name
#   content_type 'text/html'       # optional, defaults to plain/text
#   via     :sendmail              # optional, to smtp if defined, otherwise sendmail
#   render  'registration_email'
# end
#
# You can set the default delivery settings from your app through:
#
#   set :delivery_method, :smtp => {
#     :address         => 'smtp.yourserver.com',
#     :port            => '25',
#     :user_name       => 'user',
#     :password        => 'pass',
#     :authentication  => :plain, # :plain, :login, :cram_md5, no auth by default
#     :domain          => "localhost.localdomain" # the HELO domain provided by the client to the server
#   }
#
# or sendmail (default):
#
#   set :delivery_method, :sendmail
#
# or for tests:
#
#   set :delivery_method, :test
#
# and then all delivered mail will use these settings unless otherwise specified.
#

Licensing.mailer :alerts do

  email :send_confirmation do |email,radius,postcode,hash|
    from 'licensing@lichfielddc.gov.uk'
    to email
    subject "Your licensing alerts request"
    locals :radius => radius, :postcode => postcode, :hash => hash
    render 'alerts/send_confirmation'
    content_type :html 
    via :sendmail
  end

  email :send_alert do |email,radius,postcode,hash,applications|
    from 'licensing@lichfielddc.gov.uk'
    to email
    subject "There has been a new licensing application in your area"
    locals :radius => radius, :postcode => postcode, :hash => hash, :applications => applications
    render 'alerts/send_alert'
    content_type :html 
    via :sendmail
  end

end
