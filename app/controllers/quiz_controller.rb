# frozen_string_literal: true

class QuizController < ApplicationController
  class ConflictException < RuntimeError; end

  rescue_from ConflictException, with: :conflict_handler

  def conflict_handler(_exception)
    render status: :conflict, json: progress_data
  end

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
    @questions_data = questions_data
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

    patch = params.require(:patch).permit(
      :playerId, :field, :oldValue, :newValue
    )

    update_question(patch)

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
      email: "guestuser#{Random.rand(1..1e16.to_i)}@example.com",
      password: SecureRandom.alphanumeric(16),
      guest: true
    )
  end

  def update_question(patch)
    user_id = patch[:playerId]

    question_users = QuestionUser.where(
      question_id: @quiz.questions, user_id: user_id
    )

    match = field_regex.match(patch[:field])
    question_id = match[1]
    column = match[2].downcase

    question_user = question_users.find_or_create_by!(question_id: question_id)

    update_field(question_user, patch, column)
  end

  def update_field(question_user, patch, col)
    raise ActionController::BadRequest unless %w[answer points].include?(col)

    raise ConflictException if conflict?(question_user, patch[:oldValue], col)

    question_user[col] = patch[:newValue]
    question_user.save!
  end

  def conflict?(question_user, old_val, column)
    return false if [old_val, question_user[column]].all?(&:blank?)

    old_val = BigDecimal(old_val) if column == 'points' && old_val.present?
    old_val != question_user[column]
  end

  def field_regex
    /question(\d+)(Answer|Points)/
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

  def questions_data
    @quiz.questions.map do |question|
      {
        id: question.id,
        title: question.title,
        expired: question.expired
      }
    end
  end
end
