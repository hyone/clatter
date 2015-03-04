desc 'Recalculate counter cache columns in database'
task 'counter_culture:fix_counts' => :environment do |task|
  logger = Logger.new('log/tasks.log')
  logger.info "Started #{task.name}"

  [Message, Follow, Favorite, Retweet].each do |model_class|
    model_class.counter_culture_fix_counts
    logger.info "Fixed #{model_class} counters"
  end

  logger.info "Finished #{task.name}"
end
