# frozen_string_literal: true

require_relative 'base_state'

# Логика главного меню
class MenuState < BaseState
  def handle(message)
    case message.text
    when '/start', '🏠 Меню'
      show_menu(message.chat.id)
    when '/add', '➕ Добавить задачу'
      start_adding_task(message)
    when '/tasks', '📋 Мои задачи'
      show_tasks(message)
    when '/clear', '🗑️ Очистить всё'
      clear_all_tasks(message)
    when '/help', '❓ Помощь'
      show_help(message.chat.id)
    else
      handle_unknown(message)
    end
  end

  def show_menu(chat_id)
    kb = [
      [Telegram::Bot::Types::KeyboardButton.new(text: '➕ Добавить задачу')],
      [
        Telegram::Bot::Types::KeyboardButton.new(text: '📋 Мои задачи'),
        Telegram::Bot::Types::KeyboardButton.new(text: '🗑️ Очистить всё')
      ],
      [Telegram::Bot::Types::KeyboardButton.new(text: '❓ Помощь')]
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true)
    bot.api.send_message(chat_id: chat_id, text: 'Главное меню:', reply_markup: markup)
  end

  private

  def start_adding_task(message)
    db.set_state(message.from.id, 'ADDING_TASK')

    kb = [[Telegram::Bot::Types::KeyboardButton.new(text: '⬅️ Назад')]]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true)

    bot.api.send_message(chat_id: message.chat.id, text: 'Напиши, что нужно сделать:', reply_markup: markup)
  end

  def handle_unknown(message)
    bot.api.send_message(chat_id: message.chat.id, text: 'Выбери действие на клавиатуре 👇')
    show_menu(message.chat.id)
  end

  def show_tasks(message)
    tasks = db.all_tasks(message.from.id)
    return send_empty_msg(message.chat.id) if tasks.empty?

    bot.api.send_message(
      chat_id: message.chat.id,
      text: format_tasks(tasks),
      parse_mode: 'Markdown'
    )
  end

  def format_tasks(tasks)
    text = "📋 *Твой список задач (по приоритетам):*\n\n"

    tasks.each_with_index do |task, i|
      text += "#{i + 1}. #{task[:priority]} — #{task[:title]}\n"
    end

    text
  end

  # Логика полной очистки
  def clear_all_tasks(message)
    db.clear_tasks(message.from.id)

    remove_markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)

    bot.api.send_message(
      chat_id: message.chat.id,
      text: '🗑️ Список задач полностью очищен!',
      reply_markup: remove_markup
    )

    show_menu(message.chat.id)
  end

  def send_empty_msg(chat_id)
    msg = "📋 *Твои задачи:*\n\n_Список пока пуст._"
    bot.api.send_message(chat_id: chat_id, text: msg, parse_mode: 'Markdown')
  end

  def show_help(chat_id)
    help_text = "🤖 *Помощь:*\n\n" \
                "1. /add — добавить задачу\n" \
                "2. /tasks — список дел\n" \
                "3. /clear — очистить список\n" \
                '4. /start — открыть меню'
    bot.api.send_message(chat_id: chat_id, text: help_text, parse_mode: 'Markdown')
  end
end
