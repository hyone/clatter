RSpec.configure do |config|
  DatabaseCleaner = DatabaseRewinder

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # use transaction on usual tests
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # use truncation (database_cleaner) on tests with plterguist
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, truncation: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
