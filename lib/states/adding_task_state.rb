# frozen_string_literal: true

require_relative 'base_state'

# Получение текста задачи
class AddingTaskState < BaseState
  def handle(message)
    user_id = message.from.id
    chat_id = message.chat.id

    return go_back_to_menu(user_id, chat_id) if message.text == '⬅️ Назад'
    return notify_invalid_input(chat_id) if message.text.start_with?('/')

    db.add_task(user_id, message.text, 'PENDING')
    db.set_state(user_id, 'SETTING_PRIORITY')
    ask_priority(message)
  end

  private

  def notify_invalid_input(chat_id)
    text = "⚠️ *Ошибка:* Текст задачи не может начинаться с `/`.\n\nВведите название текстом:"
    bot.api.send_message(chat_id: chat_id, text: text, parse_mode: 'Markdown')
  end

  def ask_priority(message)
    kb = [
      [Telegram::Bot::Types::KeyboardButton.new(text: '🔴 Высокий')],
      [Telegram::Bot::Types::KeyboardButton.new(text: '🟡 Средний')],
      [Telegram::Bot::Types::KeyboardButton.new(text: '🟢 Низкий')],
      [Telegram::Bot::Types::KeyboardButton.new(text: '⬅️ Назад')]
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true, one_time_keyboard: true)

    bot.api.send_message(
      chat_id: message.chat.id,
      text: "Задача записана: *#{message.text}*\n\nВыбери приоритет:",
      reply_markup: markup,
      parse_mode: 'Markdown'
    )
  end
end
