class QuizController < ApplicationController
  def join
    quiz = Quiz.find_by(code: params[:code])
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
    @column_headers = column_headers
    @column_data = column_data
    @progress_data = progress_data
  end

  def update
    quiz = Quiz.find(params[:id])
    #TODO: authorize
    quiz.update!(params.require(:quiz).permit(:name, :code, :cursor))
    redirect_to edit_quiz_url id: quiz.id
  end

  def progress
    @quiz = Quiz.find(params[:quiz_id])
    @column_headers = column_headers
    @column_data = column_data
    @progress_data = progress_data
  end

  def update_progress
    @quiz = Quiz.find(params[:quiz_id])
    row = params[:row]
    user_id = row[:playerId]

    @quiz.questions.each do |question|
      question_user = QuestionUser.find_or_create_by!(
        question_id: question.id, user_id: user_id
      )
      question_user.answer = row["question#{question.id}Answer"]
      question_user.points = row["question#{question.id}Points"]
      question_user.save!
    end

    render json: progress_data
  end

  def add_guest
    @quiz = Quiz.find(params[:quiz_id])
    user = User.create!(
      nickname: params[:user][:nickname],
      email: "guestuser#{Random.rand(16)}@example.com",
      password: SecureRandom.alphanumeric(16),
      guest: true
    )
    QuestionUser.create!(
      question: @quiz.questions.first,
      user: user
    )

    render json: progress_data
  end

  private

  def column_headers
    ['Rank', 'Team', 'Total Points'] + @quiz.questions.flat_map do |question|
      [question.title, 'Points']
    end + ['Total Points']
  end

  def column_data
    cols = [
      { data: 'rank' },
      { data: 'team' },
      { data: 'totalPoints' }
    ]

    @quiz.questions.each do |question|
      tag = "question#{question.id}"
      cols << { data: "#{tag}Answer" }
      cols << { data: "#{tag}Points" }
    end

    cols << { data: 'totalPoints' }
  end

  def progress_data
    rank = 1
    points_memo = nil

    @quiz.results.map.with_index(1) do |result, i|
      rank = i if points_memo && result.total_points < points_memo
      points_memo = result.total_points

      {
        playerId: result.user_id,
        rank: rank,
        team: result.team,
        totalPoints: result.total_points
      }.tap do |data|
        @quiz.questions.each do |question|
          question_user = QuestionUser.find_by(
            question: question, user: result.user
          )
          tag = "question#{question.id}"
          data["#{tag}Answer"] = question_user&.answer
          data["#{tag}Points"] = question_user&.points
        end
      end
    end
  end
end
