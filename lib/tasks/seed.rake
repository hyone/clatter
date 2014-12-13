desc 'Load the seed data of the development environment'
task 'db:seed:development' => :environment do
  load File.join(Rails.root, 'db', 'seeds', 'development.rb')
end
