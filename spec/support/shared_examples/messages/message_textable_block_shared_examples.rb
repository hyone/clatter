
# a shared context requires conditions below:
# - path: method return path in which we test message, it is passed user and message
# - user
#
shared_examples 'a message textable block' do
  let!(:message) do
    FactoryGirl.create(:message, user: user)
  end
  let(:message_id) { "#message-#{message.id} .message-body" }
  before { visit path(message) }

  it 'should have message text' do
    should have_selector(message_id)
  end

  describe 'URL' do
    context 'with text includes URLs' do
      let(:url1) { URI('http://hoge.fuga.com/') }
      let(:url2) { URI('https://wwww.example.com/') }
      let!(:message) { FactoryGirl.create(:message, user: user, text: "hello #{url1} and #{url2}") }
      before { visit path(message) }

      it 'should become a link' do
        [url1, url2].each do |url|
          should have_link("#{url.host}#{url.path}", href: "#{url}")
        end
      end
    end

    context 'with text includes long URL' do
      let(:url) { URI('https://wwww.example.com/hoge/fuga/foofoo.txt') }
      let!(:message) { FactoryGirl.create(:message, user: user, text: "hello #{url}") }
      before { visit path(message) }

      it 'link text should be truncated' do
        should have_xpath("//a[contains(normalize-space(text()), '...')][@href='#{url}']")
      end
    end

    context 'with invalid URL' do
      let(:url) { 'www.example.com' }
      let!(:message) { FactoryGirl.create(:message, user: user, text: "hello #{url}") }
      before { visit path(message) }

      it 'should not become link' do
        should_not have_xpath("//a[@href='#{url}']")
      end
    end

    context 'with other protocols than http (https)' do
      let(:url) { 'ssh://www.example.com/' }
      let!(:message) { FactoryGirl.create(:message, user: user, text: "hello #{url}") }
      before { visit path(message) }

      it 'should not become link' do
        should_not have_xpath("//a[@href='#{url}']")
      end
    end
  end

  context 'with @screen_name' do
    let!(:reply) { FactoryGirl.create(:message_with_reply, user: user) }
    before { visit path(reply) }

    it "'@screen_name' is linked to that user page" do
      reply.users_replied_to.each do |u|
        expect(page).to have_link("@#{u.screen_name}", user_path(u))
      end
    end

    context 'when @screen_name is not an existing user' do
      let!(:reply) { FactoryGirl.create(:message, user: user, text: '@no_such_user hello!') }
      before { visit path(reply) }

      it 'should not become link' do
        should_not have_link(message_id, reply.text)
      end
    end
  end
end
