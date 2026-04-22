# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Database do
  let(:db) { Database.new }
  let(:first_user) { 111 }
  let(:second_user) { 222 }

  describe '#clear_tasks' do
    it 'удаляет задачи только конкретного пользователя' do
      db.add_task(first_user, 'Задача Юзера 1')
      db.add_task(second_user, 'Задача Юзера 2')

      db.clear_tasks(first_user)

      expect(db.all_tasks(first_user)).to be_empty
      expect(db.all_tasks(second_user)).not_to be_empty
    end
  end

  describe '#all_tasks' do
    it 'возвращает задачи пользователя' do
      db.add_task(first_user, 'Первая', '🟢 Низкий')
      db.add_task(first_user, 'Вторая', '🔴 Высокий')

      tasks = db.all_tasks(first_user)
      expect(tasks.size).to eq(2)

      titles = tasks.map { |t| t[:title] }
      expect(titles).to include('Первая', 'Вторая')
    end
  end
end
