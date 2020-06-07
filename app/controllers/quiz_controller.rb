# frozen_string_literal: true

class QuizController < ApplicationController
  def join
    quiz = Quiz.find_by(code: params[:code].upcase)
    if quiz.nil?
      flash[:error] = 'Quiz not found'
      return redirect_to root_url
    end

    redirect_to quiz_url(quiz.id)
  end

  def show
    @quiz = Quiz.find(params[:id])
    @question = Question.find_by(id: @quiz.cursor)

    return render :waiting if @question.nil?

    redirect_to quiz_question_url(quiz_id: @quiz.id, id: @question.id)
  end

  def new
    @quiz = Quiz.new(user: current_user, code: Quiz.unique_code)
  end

  def create
    quiz = Quiz.new(params.require(:quiz).permit(:name, :code))
    quiz.user = current_user
    quiz.save!
    redirect_to edit_quiz_url id: quiz.id
  end

  def edit
    @quiz = Quiz.find(params[:id])
    authorize! :update, @quiz

    @column_headers = column_headers
    @column_data = column_data
    @progress_data = progress_data
  end

  def update
    quiz = Quiz.find(params[:id])
    authorize! :update, quiz

    quiz.update!(params.require(:quiz).permit(:name, :code, :cursor))
    redirect_to edit_quiz_url id: quiz.id
  end

  def update_progress
    @quiz = Quiz.find(params[:quiz_id])
    authorize! :update, @quiz

    row = params[:row]
    update_questions(row)

    render json: progress_data
  end

  def add_guest
    @quiz = Quiz.find(params[:quiz_id])
    authorize! :update, @quiz

    user = create_guest_user
    QuestionUser.create!(
      question: @quiz.questions.first,
      user: user
    )

    render json: progress_data
  end

  private

  def create_guest_user
    User.create!(
      nickname: params[:user][:nickname],
      email: "guestuser#{Random.rand(16)}@example.com",
      password: SecureRandom.alphanumeric(16),
      guest: true
    )
  end

  def update_questions(row)
    user_id = row[:playerId]

    @quiz.questions.each do |question|
      question_user = QuestionUser.find_or_create_by!(
        question_id: question.id, user_id: user_id
      )
      question_user.answer = row["question#{question.id}Answer"]
      question_user.points = row["question#{question.id}Points"]
      question_user.save!
    end
  end

  def column_headers
    ['Rank', 'Team', 'Total Points'] + @quiz.questions.flat_map do |question|
      [question.title, 'Points']
    end + ['Total Points']
  end

  def column_data
    cols = [{ data: 'rank' }, { data: 'team' }, { data: 'totalPoints' }]

    @quiz.questions.each do |question|
      tag = "question#{question.id}"
      cols << { data: "#{tag}Answer" }
      cols << { data: "#{tag}Points" }
    end

    cols << { data: 'totalPoints' }
  end
end
