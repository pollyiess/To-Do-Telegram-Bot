# frozen_string_literal: true

require 'spec_helper'
require 'states/adding_task_state'

RSpec.describe AddingTaskState do
  let(:api) { double('api') }
  let(:bot) { double('bot', api: api) }
  let(:db) { Database.new }
  let(:user_id) { 555 }
  let(:chat_id) { 555 }
  let(:message) { double('message', from: double(id: user_id), chat: double(id: chat_id)) }

  subject { described_class.new(bot, db) }

  it 'при нажатии "Назад" возвращает в меню и не создает задачу' do
    message_back = double('message', text: '⬅️ Назад', from: double(id: user_id), chat: double(id: chat_id))

    expect(db).to receive(:set_state).with(user_id, 'MENU')
    expect(api).to receive(:send_message).with(hash_including(text: 'Главное меню:'))

    subject.handle(message_back)

    expect(db.all_tasks(user_id)).to be_empty
  end

  it 'создает задачу со статусом PENDING при вводе текста' do
    allow(message).to receive(:text).and_return('Купить молоко')
    allow(api).to receive(:send_message)

    subject.handle(message)

    pending_task = db.db[:tasks].where(user_id: user_id, priority: 'PENDING').first
    expect(pending_task[:title]).to eq('Купить молоко')
    expect(db.get_state(user_id)).to eq('SETTING_PRIORITY')
  end
end
