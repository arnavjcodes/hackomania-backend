class Quiz < ApplicationRecord
    has_many :quiz_questions, dependent: :destroy
    has_many :user_quiz_responses, dependent: :destroy
    scope :active, -> { where(active: true) }
  end