class WordGuesserGame
  attr_reader :word, :guesses, :wrong_guesses

  # add the necessary class methods, attributes, etc. here
  # to make the tests in spec/wordguesser_game_spec.rb pass.

  # Get a word from remote "random word" service

  def initialize(word)
    @word = word.to_s.strip
    @guesses = ''
    @wrong_guesses = ''
  end
  def self.from_session(state)
    game = new(state[:word] || state['word'] || '')
    game.instance_variable_set(:@guesses, state[:guesses] || state['guesses'] || '')
    game.instance_variable_set(:@wrong_guesses, state[:wrong_guesses] || state['wrong_guesses'] || '')
    game
  end
  def to_session
  {
    word: @word,
    guesses: @guesses,
    wrong_guesses: @wrong_guesses
  }
  end
  def guess(letter)
    unless letter.is_a?(String) && letter.match?(/\A[a-zA-Z]\z/)
      raise ArgumentError, 'Guess must be a single letter'
    end
    letter = letter.downcase
    return false if @guesses.include?(letter) ||
                    @wrong_guesses.include?(letter)
    if @word.downcase.include?(letter)
      @guesses += letter
    else
      @wrong_guesses += letter
    end
    true
  end

  def word_with_guesses
    @word.downcase.chars.map do |letter|
      if @guesses.include?(letter)
        letter
      else
        '-'
      end
    end.join
  end

  def check_win_or_lose
    return :play if @word.to_s.strip.empty?
    return :win if @word.downcase.chars.all? { |letter| @guesses.include?(letter) }
    return :lose if @wrong_guesses.length >= 7

    :play
  end

  # You can test it by installing irb via $ gem install irb
  # and then running $ irb -I. -r app.rb
  # And then in the irb: irb(main):001:0> WordGuesserGame.get_random_word
  #  => "cooking"   <-- some random word
  def self.get_random_word
    require 'uri'
    require 'net/http'
    uri = URI('https://esaas-randomword-27a759b6224d.herokuapp.com/RandomWord')
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      return http.post(uri, "").body
    end
  end
end
