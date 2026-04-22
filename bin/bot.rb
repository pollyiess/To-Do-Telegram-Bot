# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv/load'
require_relative '../lib/database'
require_relative '../lib/states/menu_state'
require_relative '../lib/states/adding_task_state'

token = ENV['TELEGRAM_BOT_TOKEN']
db = Database.new

Telegram::Bot::Client.run(token) do |bot|
  puts 'Бот запущен...'

  bot.listen do |message|
    # Защита: обрабатываем только текстовые сообщения от пользователей
    next unless message.is_a?(Telegram::Bot::Types::Message)
    next unless message.text

    state_name = db.get_state(message.from.id)

    case state_name
    when 'ADDING_TASK'
      AddingTaskState.new(bot, db).handle(message)
    else
      MenuState.new(bot, db).handle(message)
    end
  end
end
