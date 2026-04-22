# frozen_string_literal: true

require_relative 'base_state'
require_relative 'menu_state'

# Логика сохранения новой задачи
class AddingTaskState < BaseState
  def handle(message)
    save_task(message)
    notify_and_show_menu(message)
  end

  private

  def save_task(message)
    # Сохраняем задачу в базу данных
    db.add_task(message.from.id, message.text)
    # Переводим пользователя в состояние обычного меню
    db.set_state(message.from.id, 'MENU')
  end

  def notify_and_show_menu(message)
    # Подтверждаем сохранение
    bot.api.send_message(chat_id: message.chat.id, text: "✅ Записал: #{message.text}")

    MenuState.new(bot, db).show_menu(message.chat.id)
  end
end
