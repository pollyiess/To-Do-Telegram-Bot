# frozen_string_literal: true

require_relative 'base_state'

# Логика сохранения новой задачи
class AddingTaskState < BaseState
  def handle(message)
    save_task(message)
    return_to_menu(message)
  end

  private

  def save_task(message)
    db.add_task(message.from.id, message.text)
    db.set_state(message.from.id, 'START')
  end

  def return_to_menu(message)
    bot.api.send_message(chat_id: message.chat.id, text: "✅ Записал: #{message.text}")
    MenuState.new(bot, db).handle(message)
  end
end
