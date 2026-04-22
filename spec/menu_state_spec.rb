# frozen_string_literal: true

require 'spec_helper'
require 'states/menu_state'

RSpec.describe MenuState do
  let(:api) { double('api') }
  let(:bot) { double('bot', api: api) }
  let(:db) { Database.new }
  let(:user_id) { 888 }
  let(:message) { double('message', from: double(id: user_id), chat: double(id: 888), text: 'Какой-то бред') }

  subject { described_class.new(bot, db) }

  it 'при неизвестном вводе отправляет сообщение об ошибке и вызывает помощь' do
    expect(api).to receive(:send_message).twice

    subject.handle(message)
  end
end
