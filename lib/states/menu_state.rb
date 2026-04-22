# frozen_string_literal: true

require_relative 'base_state'

# Логика главного меню
class MenuState < BaseState
  def handle(message)
    case message.text
    when '/start', '🏠 Меню', '⬅️ Назад' then show_menu(message.chat.id)
    when '/add', '➕ Добавить задачу' then start_adding_task(message)
    when '/tasks', '📋 Мои задачи' then show_tasks(message)
    when '/clear', '🗑️ Очистить всё' then clear_all_tasks(message)
    when '/help', '❓ Помощь' then show_help(message.chat.id)
    else handle_unknown(message)
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

  def clear_all_tasks(message)
    user_id = message.from.id
    chat_id = message.chat.id

    if db.all_tasks(user_id).empty?
      send_empty_list_message(chat_id)
    else
      db.clear_tasks(user_id)

      remove_markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      bot.api.send_message(
        chat_id: chat_id,
        text: '🗑️ Все задачи удалены!',
        reply_markup: remove_markup
      )

      show_menu(chat_id)
    end
  end

  private

  def start_adding_task(message)
    db.set_state(message.from.id, 'ADDING_TASK')
    kb = [[Telegram::Bot::Types::KeyboardButton.new(text: '⬅️ Назад')]]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true)
    bot.api.send_message(chat_id: message.chat.id, text: 'Напиши, что нужно сделать:', reply_markup: markup)
  end

  def handle_unknown(message)
    bot.api.send_message(
      chat_id: message.chat.id,
      text: "Я не знаю команды *#{message.text}* 🤔",
      parse_mode: 'Markdown'
    )
    show_help(message.chat.id)
  end

  def show_tasks(message)
    tasks = db.all_tasks(message.from.id)
    return send_empty_list_message(message.chat.id) if tasks.empty?

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

  def show_help(chat_id)
    help_text = "🤖 *Быстрая справка по командам:*\n\n" \
                "• *Добавить задачу* - бот спросит текст и приоритет.\n" \
                "• *Мои задачи* - покажет список по важности.\n" \
                "• *Очистить всё* - полное удаление списка.\n\n" \
                'Выбери действие кнопкой ниже 👇'

    bot.api.send_message(chat_id: chat_id, text: help_text, reply_markup: help_markup, parse_mode: 'Markdown')
  end

  def help_markup
    kb = [
      [Telegram::Bot::Types::KeyboardButton.new(text: '➕ Добавить задачу')],
      [Telegram::Bot::Types::KeyboardButton.new(text: '📋 Мои задачи')],
      [Telegram::Bot::Types::KeyboardButton.new(text: '🗑️ Очистить всё')]
    ]
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true)
  end
end
