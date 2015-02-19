
def fill_in_textarea(prefix, text)
  fill_in "#{prefix}-message-form-text", with: text
end


# a shared context requires conditions below:
# - let(:prefix) { 'prefix' }
#
# type = :normal
#   modal message form
# type = :foldable
#   foldable message form

shared_examples 'a postable form' do |type = :modal|

  context 'with empty text', js: true  do
    it 'post button should be disabled' do
      expect(page).to have_selector("\##{prefix}-message-form-submit:disabled")
    end

    if type == :foldable
      context 'and then when blur the textarea' do
        before {
          page.find("\##{prefix}-message-form-text").trigger('blur')
        }
        it 'submit button should be hidden' do
          # wait until the form have hidden
          sleep 0.1
          expect(page.find("\##{prefix}-message-form-submit", visible: false)).not_to be_visible
        end
      end
    end
  end

  context 'with some text', js: true  do
    before { fill_in "#{prefix}-message-form-text", with: 'Hello World' }

    it 'post button should be enabled' do
      expect(page).to have_selector("\##{prefix}-message-form-submit")
      expect(page).not_to have_selector("\##{prefix}-message-form-submit:disabled")
    end

    it 'should display textarea count in normal color' do
      expect(page).not_to have_selector("\##{prefix}-message-form .text-danger")
    end

    if type == :foldable
      context 'and then when blur the textarea' do
        before {
          page.find("\##{prefix}-message-form-text").trigger('blur')
        }
        it 'submit button should be visible' do
          expect(page.find("\##{prefix}-message-form-submit")).to be_visible
        end
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
        specify 'content should be cleared' do
          submit
          wait_for_ajax
          expect(find("\##{prefix}-message-form-text").value).to be_empty
        end

        it 'should be blurred' do
          textarea_id = "\##{prefix}-message-form-text"
          submit
          wait_for_ajax
          expect(blur?(textarea_id)).to be_truthy
        end
      end
    end

    context 'when click submit button' do
      include_examples 'new message creatable' do
        def submit
          click_button "#{prefix}-message-form-submit"
        end
      end
    end

    def hit_key(ctrl: false, meta: false)
      page.execute_script <<-EOC
        var e = $.Event('keydown', { keyCode: 13, ctrlKey: true, metaKey: false });
        $('##{prefix}-message-form-text').trigger(e);
      EOC
    end

    context 'when hit ctrl+enter' do
      include_examples 'new message creatable' do
        def submit
          hit_key(ctrl: true, meta: false)
        end
      end
    end

    context 'when hit command+enter' do
      include_examples 'new message creatable' do
        def submit
          hit_key(ctrl: false, meta: true)
        end
      end
    end
  end

  context "with text that's length is near limit", js: true  do
    before { fill_in "#{prefix}-message-form-text", with: 'a' * 131 }

    it 'should display textarea count in danger color' do
      expect(page).to have_selector("\##{prefix}-message-form .text-danger")
    end
  end

  context 'with too long text', js: true  do
    before { fill_in "#{prefix}-message-form-text", with: 'a' * 141 }
    it 'post button should be disabled' do
      expect(page).to have_selector("\##{prefix}-message-form-submit:disabled")
    end

    it 'should display textarea count in danger color' do
      expect(page).to have_selector("\##{prefix}-message-form .text-danger")
    end
  end
end
