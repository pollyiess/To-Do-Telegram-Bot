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

# Карта состояний для быстрого доступа
STATES = {
  'ADDING_TASK' => AddingTaskState,
  'SETTING_PRIORITY' => SettingPriorityState
}.freeze

loop do
  Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |update|
      user_id = update.respond_to?(:from) ? update.from.id : nil
      next unless user_id

      state_name = db.get_state(user_id)

      state_class = STATES[state_name] || MenuState
      state_instance = state_class.new(bot, db)

      begin
        state_instance.handle(update)
      rescue Telegram::Bot::Exceptions::ResponseError => e
        puts "Ошибка API Telegram: #{e.message}"
      rescue StandardError => e
        puts "Ошибка выполнения [#{state_name}]: #{e.class} - #{e.message}"
        puts e.backtrace.first(3)
      end
    end
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    puts "Проблемы с сетью: #{e.message}. Сплю 5 секунд..."
    sleep 5
  rescue StandardError => e
    puts "Критический сбой клиента: #{e.message}"
    sleep 2
  end
end
