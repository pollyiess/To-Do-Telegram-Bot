# frozen_string_literal: true

require_relative 'base_state'
require_relative 'menu_state'

# Состояние для установки приоритета выбранной задаче
class SettingPriorityState < BaseState
  def handle(message)
    return handle_back_button(message) if message.text == '⬅️ Назад'

    process_priority_selection(message)
  end

  private

  def handle_back_button(message)
    cancel_task(message.from.id)
    return_to_menu(message.from.id, message.chat.id)
  end

  def process_priority_selection(message)
    user_id = message.from.id
    last_task = find_pending_task(user_id)

    if last_task
      update_priority(last_task[:id], message.text)
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "✅ Готово! Задача с приоритетом «#{message.text}» добавлена."
      )
    end

    return_to_menu(user_id, message.chat.id)
  end

  def cancel_task(user_id)
    db.db[:tasks].where(user_id: user_id, priority: 'PENDING').delete
  end

  def find_pending_task(user_id)
    db.db[:tasks]
      .where(user_id: user_id, priority: 'PENDING')
      .order(Sequel.desc(:id))
      .first
  end

  def update_priority(task_id, priority)
    db.db[:tasks].where(id: task_id).update(priority: priority)
  end

  def return_to_menu(user_id, chat_id)
    db.set_state(user_id, 'MENU')
    MenuState.new(bot, db).show_menu(chat_id)
  end
end
