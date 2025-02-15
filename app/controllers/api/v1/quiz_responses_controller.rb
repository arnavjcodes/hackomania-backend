module Api::V1
    class QuizResponsesController < ApplicationController
      before_action :authenticate_user!

      def create
        # Find the quiz and validate its existence
        quiz = Quiz.find_by(id: params[:quiz_id])
        return render json: { error: "Quiz not found" }, status: :not_found unless quiz

        # Validate the responses parameter
        unless params[:responses].is_a?(Hash)
          return render json: { error: "Invalid responses format" }, status: :unprocessable_entity
        end

        begin
          ActiveRecord::Base.transaction do
            params[:responses].each do |question_id, answer_id|
              # Convert string IDs to integers
              question_id = question_id.to_i
              answer_id = answer_id.to_i

              # Validate the question exists in this quiz
              unless quiz.quiz_questions.exists?(id: question_id)
                raise "Invalid question ID: #{question_id}"
              end

              # Validate the answer exists for this question
              unless QuizAnswer.exists?(id: answer_id, quiz_question_id: question_id)
                raise "Invalid answer ID: #{answer_id} for question #{question_id}"
              end

              current_user.user_quiz_responses.create!(
                quiz: quiz,
                quiz_question_id: question_id,
                quiz_answer_id: answer_id
              )
            end
          end

          current_user.calculate_interests!
          render json: {
            message: "Quiz responses saved",
            interests: current_user.interests
          }
        rescue ActiveRecord::RecordInvalid => e
          render json: { error: "Validation failed: #{e.message}" },
                 status: :unprocessable_entity
        rescue => e
          render json: { error: e.message },
                 status: :unprocessable_entity
        end
      end

      private

      def quiz_response_params
        params.require(:quiz_response).permit(
          :quiz_id,
          responses: {}
        )
      end
    end
end
