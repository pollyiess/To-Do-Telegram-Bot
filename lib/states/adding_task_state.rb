# frozen_string_literal: true

require_relative 'base_state'
require_relative 'menu_state'

# Получение текста задачи
class AddingTaskState < BaseState
  def handle(message)
    return go_back(message) if message.text == '⬅️ Назад'

    db.add_task(message.from.id, message.text, 'PENDING')
    db.set_state(message.from.id, 'SETTING_PRIORITY')
    ask_priority(message)
  end

  private

  def ask_priority(message)
    kb = [
      [Telegram::Bot::Types::KeyboardButton.new(text: '🔴 Высокий')],
      [Telegram::Bot::Types::KeyboardButton.new(text: '🟡 Средний')],
      [Telegram::Bot::Types::KeyboardButton.new(text: '🟢 Низкий')],
      [Telegram::Bot::Types::KeyboardButton.new(text: '⬅️ Назад')]
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: kb,
      resize_keyboard: true,
      one_time_keyboard: true
    )

    bot.api.send_message(
      chat_id: message.chat.id,
      text: "Задача записана: *#{message.text}*\n\nВыбери приоритет задачи:",
      reply_markup: markup,
      parse_mode: 'Markdown'
    )
  end

  def go_back(message)
    db.set_state(message.from.id, 'MENU')
    MenuState.new(bot, db).show_menu(message.chat.id)
  end
end
