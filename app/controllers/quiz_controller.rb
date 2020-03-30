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
  end

  def update
    quiz = Quiz.find(params[:id])
    #TODO: authorize
    quiz.update!(params.require(:quiz).permit(:name, :code, :cursor))
    redirect_to edit_quiz_url id: quiz.id
  end

  def progress
    @quiz = Quiz.find(params[:quiz_id])
    players = @quiz.players
    questions = @quiz.questions
    @column_headers = column_headers
    @rows = players.map do |player|
      row = [player.nickname, @quiz.points_for(player), @quiz.rank(player)]
      row += @quiz.questions.flat_map do |question|
        question_user = QuestionUser.find_by(
          question_id: question, user: player
        )
        [question_user&.answer, question_user&.points]
      end
    end
  end

  private

  def column_headers
    ['Team', 'Total Points', 'Rank'] + @quiz.questions.flat_map do |question|
      [question.title, 'Points']
    end
  end
end
