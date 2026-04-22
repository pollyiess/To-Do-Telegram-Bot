# frozen_string_literal: true

require 'spec_helper'
require 'states/setting_priority_state'

RSpec.describe SettingPriorityState do
  let(:api) { double('api') }
  let(:bot) { double('bot', api: api) }
  let(:db) { Database.new }
  let(:user_id) { 777 }
  let(:message) { double('message', from: double(id: user_id), chat: double(id: 777)) }

  subject { described_class.new(bot, db) }

  before do
    db.add_task(user_id, 'Черновик', 'PENDING')
    allow(api).to receive(:send_message)
  end

  it 'удаляет PENDING задачу при нажатии Назад' do
    db.add_task(user_id, 'Черновик', 'PENDING')

    allow(message).to receive(:text).and_return('⬅️ Назад')

    subject.handle(message)

    remaining_task = db.db[:tasks].where(user_id: user_id, priority: 'PENDING').first
    expect(remaining_task).to be_nil
  end

  it 'обновляет приоритет и завершает создание задачи' do
    allow(message).to receive(:text).and_return('🔴 Высокий')

    subject.handle(message)

    task = db.db[:tasks].where(user_id: user_id).first
    expect(task[:priority]).to eq('🔴 Высокий')
    expect(db.get_state(user_id)).to eq('MENU')
  end
end
