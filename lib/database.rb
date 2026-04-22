# frozen_string_literal: true

require 'sequel'
require 'sqlite3'

# Класс для управления базой данных SQLite и хранения состояний пользователей
class Database
  def initialize
    @db = Sequel.sqlite('db/todo_bot.sqlite3')
    setup_tables
  end

  # rubocop:disable Metrics/MethodLength
  def setup_tables
    # Таблица для задач
    @db.create_table? :tasks do
      primary_key :id
      Integer :user_id
      String :title, null: false
      String :priority, default: 'Medium'
      TrueClass :completed, default: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
    # rubocop:enable Metrics/MethodLength

    # Таблица для состояний пользователя
    @db.create_table? :users do
      primary_key :id
      Integer :telegram_id, unique: true
      String :state, default: 'START'
    end
  end

  # Метод для смены состояния
  def set_state(telegram_id, state)
    if @db[:users].first(telegram_id: telegram_id)
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
  def add_task(telegram_id, text)
    @db[:tasks].insert(user_id: telegram_id, title: text)
  end
end
