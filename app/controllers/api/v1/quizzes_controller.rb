module Api::V1
    class QuizzesController < ApplicationController
      before_action :authenticate_user!
  
      def index
        quizzes = Quiz.active.includes(quiz_questions: :quiz_answers)
        render json: quizzes.as_json(include: {
          quiz_questions: {
            include: :quiz_answers
          }
        })
      end
    end
  end