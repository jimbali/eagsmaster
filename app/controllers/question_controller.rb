# frozen_string_literal: true

class QuestionController < ApplicationController
  def show
    @quiz = Quiz.find(params[:quiz_id])
    @question = Question.find(params[:id])
    return redirect_to current_question_url if @quiz.cursor != @question.id

    @question_user = question_user(@question.id)
    @results = progress_data

    return render :answer_summary if @question.expired

    return render :enter_answer if @question_user.answer.nil?

    render :waiting
  end

  def submit_answer
    @question_user = question_user(params[:question_id])
    authorize! :update, @question_user

    return head :bad_request if @question_user.question.expired

    @question_user.answer = params[:answer]
    @question_user.save!

    redirect_to quiz_question_url(
      id: params[:question_id], quiz_id: params[:quiz_id]
    )
  end

  def create
    quiz = Quiz.find(params[:quiz_id])
    authorize! :update, quiz

    quiz.questions << Question.new(params.require(:question).permit(:title))
    quiz.save!
    redirect_to edit_quiz_url id: quiz.id
  end

  def update
    question = Question.find(params[:id])
    authorize! :update, question

    question.update!(params.require(:question).permit(:title, :expired))
    question.save!
    render json: question.to_json
  end

  def destroy
    question = Question.find(params[:id])
    authorize! :destroy, question

    question.destroy!
  end

  private

  def question_user(question_id)
    QuestionUser.find_or_create_by(
      user_id: current_user.id,
      question_id: question_id
    )
  end

  def current_question_url
    return quiz_url(@quiz.id) unless @quiz.cursor && @quiz.cursor > 0

    quiz_question_url(id: @quiz.cursor, quiz_id: @quiz.id)
  end
end
