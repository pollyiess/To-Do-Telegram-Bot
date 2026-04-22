# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv/load'
require_relative '../lib/database'
require_relative '../lib/states/menu_state'
require_relative '../lib/states/adding_task_state'

token = ENV['TELEGRAM_BOT_TOKEN']
db = Database.new

puts 'Бот запущен...'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    next unless message.text

    # Достаем состояние юзера из SQLite
    current_state_name = db.get_state(message.from.id)

    # Выбираем обработчик
    handler = if current_state_name == 'ADDING_TASK'
                AddingTaskState.new(bot, db)
              else
                MenuState.new(bot, db)
              end

    handler.handle(message)
  end
end
