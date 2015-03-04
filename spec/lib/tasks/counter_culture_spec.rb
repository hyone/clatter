require 'rails_helper'


describe 'counter_culture:fix_counts' do
  include_context 'rake'

  its(:prerequisites) { should include('environment') }

  it "should call 'counter_culture_fix_counts' methods" do
    [Message, Follow, Favorite, Retweet].each do |model_class|
      expect(model_class).to receive(:counter_culture_fix_counts)
    end
    subject.invoke
  end
end
