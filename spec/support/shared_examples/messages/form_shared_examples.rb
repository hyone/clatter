def form_id
  "#{ prefix }-message-form"
end

def textarea_id
  "#{ form_id }-text"
end

def submit_id
  "#{ form_id }-submit"
end

def fill_in_textarea(text)
  fill_in textarea_id, with: text
end

def textarea_content
  page.find("\##{textarea_id}").value
end

def focus_textarea
  page.find("\##{textarea_id}").trigger('focus')
end

def blur_textarea
  page.find("\##{textarea_id}").trigger('blur')
end


shared_examples 'post button is disabled' do
  it 'post button should be disabled', js: true do
    expect(page).to have_selector("\##{submit_id}:disabled")
  end
end

shared_examples 'post button is enabled' do
  it 'post button should be enabled', js: true do
    expect(page).to have_selector("\##{submit_id}")
    expect(page).not_to have_selector("\##{submit_id}:disabled")
  end
end

shared_examples 'form is opened' do
  it 'form should be opened', js: true do
    expect(page.find("\##{submit_id}")).to be_visible
  end
end

shared_examples 'form is folded' do
  it 'form should be folded', js: true do
    expect(page.find("\##{submit_id}", visible: false)).not_to be_visible
  end
end

shared_examples 'textarea counter is danger color' do
  it 'should display textarea count in danger color' do
    expect(page).to have_selector("\##{form_id} .text-danger")
  end
end


# a shared context requires conditions below:
# - let(:prefix) { 'prefix' }
#
# type = :normal
#   modal message form
# type = :foldable
#   foldable message form

shared_examples 'a new postable form' do |type = :modal|
  if type == :foldable
    include_examples 'form is folded'
  end

  context 'when focus on textarea', js: true do
    before { focus_textarea }

    if type == :foldable
      include_examples 'form is opened'
    end

    context 'with empty text' do
      include_examples 'post button is disabled'

      if type == :foldable
        context 'and then when blur the textarea' do
          before { blur_textarea }
          include_examples 'form is folded'
        end
      end
    end

    context 'with some text' do
      before { fill_in_textarea 'Hello World' }

      include_examples 'post button is enabled'

      it 'should display textarea count in normal color' do
        expect(page).not_to have_selector("\##{form_id} .text-danger")
      end

      if type == :foldable
        context 'and then when blur the textarea' do
          before { blur_textarea }
          include_examples 'form is opened'
        end
      end


      shared_examples 'new message creatable' do
        it 'should create a new message' do
          expect {
            submit
            wait_for_ajax
          }.to change(Message, :count).by(1)
        end

        describe 'textarea' do
          before {
            submit
            wait_for_ajax
          }

          it 'content should be cleared' do
            expect(textarea_content).to be_empty
          end

          it 'should be blurred' do
            expect(blur?('#' + textarea_id)).to be_truthy
          end
        end
      end

      context 'when click post button' do
        include_examples 'new message creatable' do
          def submit
            click_button submit_id
          end
        end
      end

      def hit_enter_key(ctrl: false, meta: false)
        page.execute_script <<-EOC
          var e = $.Event('keydown', { keyCode: 13, ctrlKey: true, metaKey: false });
          $('##{textarea_id}').trigger(e);
        EOC
      end

      context 'when hit ctrl+enter' do
        include_examples 'new message creatable' do
          def submit
            hit_enter_key(ctrl: true, meta: false)
          end
        end
      end

      context 'when hit command+enter' do
        include_examples 'new message creatable' do
          def submit
            hit_enter_key(ctrl: false, meta: true)
          end
        end
      end
    end

    context "with text that's length is near limit", js: true  do
      before { fill_in_textarea 'a' * 131 }
      include_examples 'textarea counter is danger color'
    end

    context 'with too long text', js: true  do
      before { fill_in_textarea 'a' * 141 }
      include_examples 'post button is disabled'
      include_examples 'textarea counter is danger color'
    end
  end
end


# a shared context requires variables below:
# - let(:prefix)  { 'prefix' }
# - let(:message) { ... }
#
shared_examples 'a replyable form' do |type = :modal|
  context 'when focus on textarea', js: true do
    before { focus_textarea }

    it "textarea should include '@screen_name'" do
      expect(textarea_content).to include("@#{message.user.screen_name}")
    end

    include_examples 'post button is disabled'

    if type == :foldable
      context 'and then when blur textarea' do
        before { blur_textarea }
        include_examples 'form is folded'
      end
    end

    context 'and then when modify content' do
      context 'with modifying only trailing spaces' do
        before {
          fill_in_textarea(textarea_content + '   ')
          focus_textarea
        }
        include_examples 'post button is disabled'

        if type == :foldable
          context 'and then when blur textarea' do
            before { blur_textarea }
            include_examples 'form is folded'
          end
        end
      end

      context 'with appending text' do
        before {
          fill_in_textarea textarea_content + 'hello!!'
          focus_textarea
        }
        include_examples 'post button is enabled'

        if type == :foldable
          context 'and then when blur textarea' do
            before { blur_textarea }
            include_examples 'form is opened'
          end
        end
      end
    end
  end
end


# a shared context requires variables below:
# - let(:prefix)  { 'prefix' }
# - let(:message) { ... }     # message.user must be different person from the logined user
# - let(:reply)   { ... }     # must be reply of message
#
shared_examples 'a multi replyable form' do
  before { focus_textarea }

  it 'text should include @screen_name of all reply users except logined user', js: true do
    expect(textarea_content).to \
      include("@#{reply.user.screen_name}").and \
      include("@#{message.user.screen_name}")
  end
end
