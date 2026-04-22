# frozen_string_literal: true

require_relative 'base_state'

# Логика главного меню
class MenuState < BaseState
  def handle(message)
    case message.text
    when '/start', '🏠 Меню'
      show_menu(message.chat.id)
    when '➕ Добавить задачу'
      start_adding_task(message)
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'Выбери действие на клавиатуре 👇')
    end
  end

  private

  def start_adding_task(message)
    db.set_state(message.from.id, 'ADDING_TASK')
    bot.api.send_message(chat_id: message.chat.id, text: 'Напиши, что нужно сделать:')
  end

  def show_menu(chat_id)
    kb = [
      [Telegram::Bot::Types::KeyboardButton.new(text: '➕ Добавить задачу')],
      [Telegram::Bot::Types::KeyboardButton.new(text: '📋 Мои задачи')]
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true)
    bot.api.send_message(chat_id: chat_id, text: 'Главное меню:', reply_markup: markup)
  end
end
