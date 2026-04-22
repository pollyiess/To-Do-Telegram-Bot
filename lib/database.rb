# frozen_string_literal: true

require 'sequel'
require 'sqlite3'

class Database
  attr_reader :db

  def initialize
    @db = Sequel.sqlite('db/todo_bot.sqlite3')
    setup_tasks_table
    setup_users_table
  end

  # Метод для смены состояния
  def set_state(telegram_id, state)
    user = @db[:users].first(telegram_id: telegram_id)
    if user
      @db[:users].where(telegram_id: telegram_id).update(state: state)
    else
      @db[:users].insert(telegram_id: telegram_id, state: state)
    end
  end

  # Метод для получения текущего состояния
  def get_state(telegram_id)
    user = @db[:users].first(telegram_id: telegram_id)
    user ? user[:state] : 'START'
  end

  # Метод для добавления новой задачи
  def add_task(telegram_id, text, priority = '🟡 Средний')
    @db[:tasks].insert(
      user_id: telegram_id,
      title: text,
      priority: priority,
      created_at: Sequel::CURRENT_TIMESTAMP
    )
  end

  # Получить список задач, отсортированный по важности
  def all_tasks(telegram_id)
    @db[:tasks]
      .where(user_id: telegram_id)
      .order(priority_order, Sequel.desc(:created_at))
      .all
  end

  # Удалить все задачи пользователя
  def clear_tasks(telegram_id)
    @db[:tasks].where(user_id: telegram_id).delete
  end

  private

  def setup_tasks_table
    @db.create_table? :tasks do
      primary_key :id
      Integer :user_id
      String :title, null: false
      String :priority, default: '🟡 Средний'
      TrueClass :completed, default: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  def setup_users_table
    @db.create_table? :users do
      primary_key :id
      Integer :telegram_id, unique: true
      String :state, default: 'START'
    end
  end

  def priority_order
    Sequel.case(
      { { priority: '🔴 Высокий' } => 1,
        { priority: '🟡 Средний' } => 2,
        { priority: '🟢 Низкий' } => 3 },
      4
    )
  end
end
