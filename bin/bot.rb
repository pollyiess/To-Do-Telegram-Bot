# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv/load'
require_relative '../lib/database'
require_relative '../lib/states/menu_state'
require_relative '../lib/states/adding_task_state'
require_relative '../lib/states/setting_priority_state'

token = ENV.fetch('TELEGRAM_BOT_TOKEN', nil)
db = Database.new

puts 'Бот запущен...'

# Внешний цикл для автоматического перезапуска при критических сбоях сети
loop do
  Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
      next unless message.is_a?(Telegram::Bot::Types::Message) && message.text

      state_name = db.get_state(message.from.id)

      case state_name
      when 'ADDING_TASK'
        AddingTaskState.new(bot, db).handle(message)
      when 'SETTING_PRIORITY'
        SettingPriorityState.new(bot, db).handle(message)
      else
        MenuState.new(bot, db).handle(message)
      end
    rescue Telegram::Bot::Exceptions::ResponseError => e
      puts "Ошибка API (возможно, бот заблокирован): #{e.message}"
    rescue StandardError => e
      puts "Произошла ошибка: #{e.class} - #{e.message}"
    end
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    puts "Проблемы с сетью: #{e.message}. Повторная попытка через 5 секунд..."
    sleep 5
  end
end
