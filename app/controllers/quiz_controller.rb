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

  def update_points
    Rails.logger.debug(params)
    question_user = QuestionUser.find_by(
      user_id: params[:userId], question_id: params[:questionId]
    )
    question_user.points = params['points']
    question_user.save!
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
    cols
  end

  def progress_data
    @quiz.players.map do |player|
      data = {
        playerId: player.id,
        rank: 'rank',
        team: player.nickname,
        totalPoints: @quiz.points_for(player)
      }.tap do |data|
        @quiz.questions.each do |question|
          question_user = QuestionUser.find_by(
            question: question, user: player
          )
          tag = "question#{question.id}"
          data["#{tag}Answer"] = question_user&.answer
          data["#{tag}Points"] = question_user&.points
        end
      end
    end
  end
end
