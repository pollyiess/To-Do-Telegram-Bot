# frozen_string_literal: true

require_relative 'base_state'
require_relative 'menu_state'

# Состояние для установки приоритета выбранной задаче
class SettingPriorityState < BaseState
  def handle(message)
    user_id = message.from.id
    chat_id = message.chat.id

    return handle_back_button(user_id, chat_id) if message.text == '⬅️ Назад'

    process_priority_selection(user_id, chat_id, message.text)
  end

  private

  def handle_back_button(user_id, chat_id)
    db.delete_pending_tasks(user_id)
    return_to_menu(user_id, chat_id)
  end

  def process_priority_selection(user_id, chat_id, priority_text)
    last_task = db.find_pending_task(user_id)

    if last_task
      db.update_task_priority(last_task[:id], priority_text)
      bot.api.send_message(
        chat_id: chat_id,
        text: "✅ Готово! Задача с приоритетом «#{priority_text}» добавлена."
      )
    end

    return_to_menu(user_id, chat_id)
  end

  def return_to_menu(user_id, chat_id)
    db.set_state(user_id, 'MENU')
    MenuState.new(bot, db).show_menu(chat_id)
  end
end
