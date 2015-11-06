require 'bundler'
Bundler.require(:default)
$LOAD_PATH << File.join(__dir__, 'lib')

Rake.add_rakelib 'lib/tasks'

task :environment do
  Pony.options = {
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'heroku.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  }
end