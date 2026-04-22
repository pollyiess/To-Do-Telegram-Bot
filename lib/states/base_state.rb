# frozen_string_literal: true

# Базовый класс для всех состояний
class BaseState
  attr_reader :bot, :db

  def initialize(bot, db)
    @bot = bot
    @db = db
  end

  def handle(message)
    raise NotImplementedError, 'Метод handle должен быть реализован!'
  end
end
