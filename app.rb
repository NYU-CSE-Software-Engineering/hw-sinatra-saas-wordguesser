require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  set :session_secret, ENV.fetch('SESSION_SECRET'){
    'wordguesser-local-development-secret-2026-keep-this-stable-123456789'
  }

  enable :sessions
  register Sinatra::Flash

  set :host_authorization, { permitted_hosts: [] }

  before do
    state = session[:game]
    @game = if state.is_a?(Hash) && (state[:word] || state['word'])
              WordGuesserGame.from_session(session[:game])
            else
              WordGuesserGame.new('')
            end
  end


  after do
    session[:game] = @game.to_session if @game
  end

  # These two routes are good examples of Sinatra syntax
  # to help you with the rest of the assignment
  get '/' do
    redirect '/new'
  end

  get '/new' do
    erb :new
  end

  post '/create' do
    # NOTE: don't change next line - it's needed by autograder!
    word = params[:word] || WordGuesserGame.get_random_word
    # NOTE: don't change previous line - it's needed by autograder!

    @game = WordGuesserGame.new(word)
    redirect '/show'
  end

  # Use existing methods in WordGuesserGame to process a guess.
  # If a guess is repeated, set flash[:message] to "You have already used that letter."
  # If a guess is invalid, set flash[:message] to "Invalid guess."
  post '/guess' do
    letter=params[:guess].to_s[0]
    begin
      valid=@game.guess(letter)
      flash[:message]="You have already used that letter." if valid == false
    rescue ArgumentError
      flash[:message]="Invalid guess."
    end
    redirect '/show'
  end

  # Everytime a guess is made, we should eventually end up at this route.
  # Use existing methods in WordGuesserGame to check if player has
  # won, lost, or neither, and take the appropriate action.
  # Notice that the show.erb template expects to use the instance variables
  # wrong_guesses and word_with_guesses from @game.
  get '/show' do
    case @game.check_win_or_lose
    when :win
      redirect '/win'
    when :lose
      redirect '/lose'
    else
      erb :show # You may change/remove this line
    end
  end

  get '/win' do
    redirect '/show' unless @game.check_win_or_lose == :win
    erb :win # You may change/remove this line
  end

  get '/lose' do
    redirect '/show' unless @game.check_win_or_lose == :lose
    erb :lose # You may change/remove this line
  end
end
