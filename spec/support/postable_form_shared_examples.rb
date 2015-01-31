
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
          page.find('#content-main-message-form-text').trigger('blur')
        }
        it 'submit button should be hidden' do
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
          page.find('#content-main-message-form-text').trigger('blur')
        }
        it 'submit button should be visible' do
          expect(page.find("\##{prefix}-message-form-submit")).to be_visible
        end
      end
    end

    context 'after submit' do
      it 'should create a new message' do
        expect {
          click_button "#{prefix}-message-form-submit"
          wait_for_ajax
        }.to change(Message, :count).by(1)
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
