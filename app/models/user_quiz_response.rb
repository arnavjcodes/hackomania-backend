class UserQuizResponse < ApplicationRecord
    belongs_to :user
    belongs_to :quiz
    belongs_to :quiz_question
    belongs_to :quiz_answer
  end