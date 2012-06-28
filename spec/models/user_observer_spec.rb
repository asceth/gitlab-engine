require 'spec_helper'

describe GitlabEngine::UserObserver do
  subject { GitlabEngine::UserObserver.instance }

  it 'calls #after_create when new users are created' do
    new_user = Factory.new(:user)
    subject.should_receive(:after_create).with(new_user)

    User.observers.enable 'GitlabEngine::UserObserver' do
      new_user.save
    end
  end

  context 'when a new user is created' do
    let(:user) { double(:user, id: 42, password: 'nope') }
    let(:notification) { double :notification }

    it 'sends an email' do
      notification.should_receive(:deliver)
      GitlabEngine::Notify.should_receive(:new_user_email).with(user.id, user.password).and_return(notification)

      subject.after_create(user)
    end
  end
end
