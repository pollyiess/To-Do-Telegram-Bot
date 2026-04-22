# frozen_string_literal: true

# Базовый класс для всех состояний
class BaseState
  attr_reader :bot, :db

  def initialize(bot, db)
    @bot = bot
    @db = db
  end

  def handle(_message)
    raise NotImplementedError, 'Метод handle должен быть реализован!'
  end

  # Универсальный метод возврата в меню
  def go_back_to_menu(user_id, chat_id)
    db.set_state(user_id, 'MENU')
    require_relative 'menu_state'
    MenuState.new(bot, db).show_menu(chat_id)
  end

  # Общий метод для уведомления о пустом списке
  def send_empty_list_message(chat_id)
    bot.api.send_message(chat_id: chat_id, text: 'Список задач пуст.')
    db.set_state(chat_id, 'MENU')
  end
end
