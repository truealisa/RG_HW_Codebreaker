require 'readline'
require 'yaml'
require 'date'

module RgHwCodebreaker
  # Class Cli responsible for console communication with player
  class Cli
    def initialize
      @menu = { main_menu: %w[start_game best_results help],
                in_game_menu: %w[submit_guess hint go_to_main_menu],
                after_game_menu: %w[play_again go_to_main_menu],
                short_menu: %w[go_to_main_menu] }
      @current_menu = :main_menu
      @welcome_msg = "Welcome to CODEBREAKER!\n\n"
      @help_msg = "HELP\n\nCodebreaker is a logic game where you will have to "\
                  'break a secret code generated by your computer. Secret '\
                  'code is a four-digit number where each digit is in the '\
                  'range from 1 to 6. You have 10 turns to guess. Each turn '\
                  'you have to input four digits and system will return you '\
                  "up to four '+' and '-' signs. A '+' indicates an exact "\
                  'match: one of the digits in the guess is the same as one '\
                  'of the digits in the secret code and in the same position. '\
                  "A '-' indicates a number match: one of the numbers in the "\
                  'guess is the same as one of the numbers in the secret code '\
                  "but in a different position.\n\nGood luck!\n\n"
      @game_msg = "GAME\n\nSecret code was generated.\nIt is your turn. "\
                  "Choose 'Submit guess' to make a guess (must include four "\
                  'digits in the range from 1 to 6! elsewise it will be '\
                  "rejected).\n\nNOTE 1: If you go to main menu or exit your "\
                  "current game will be lost.\nNOTE 2: Use hint to open one "\
                  "digit from secret code.\n\n"
      @win_msg = "You won! Congrats!\n\n"
      @lose_msg = "You lost... Try again\n\n"
      @exit_break = false
    end

    def run
      greet
      print_menu
      repl
    end

    def greet
      print @welcome_msg
    end

    def print_menu
      @menu[@current_menu].each_with_index do |menu_item, index|
        puts((index + 1).to_s + ' - ' + menu_item.gsub(/[_]/, ' ').capitalize)
      end
      puts "0 - Exit\n\n"
    end

    def repl
      loop do
        break if @exit_break
        input = Readline.readline('> ')
        handle_input(input)
      end
    end

    def handle_input(input)
      if input == '0'
        @exit_break = true
      else
        selected_action = nil
        @menu[@current_menu].each_with_index do |menu_item, index|
          selected_action = menu_item if input == (index + 1).to_s
        end
        if selected_action.nil?
          puts "Select valid option to continue!\n\n"
          print_menu
        else
          eval(selected_action)
        end
      end
    end

    def start_game
      @current_menu = :in_game_menu
      @game = Game.new
      @game.start
      puts @game_msg
      print_turns
      print_menu
    end
    alias play_again start_game

    def print_turns
      puts "Turns left: #{@game.instance_variable_get(:@turns)}\n\n"
    end

    def submit_guess
      puts @game.inspect
      puts 'Your guess:'
      guess = Readline.readline('>>> ')
      if valid_guess?(guess)
        guess_result = @game.check_guess(guess)
        handle_guess_result(guess_result)
      else
        puts "Your input is invalid!\n\n"
      end
      print_menu
    end

    def valid_guess?(guess)
      if guess.size == 4 && guess.chars.all? { |char| char.to_i.between?(1, 6) }
        true
      else
        false
      end
    end

    def handle_guess_result(guess_result)
      if guess_result[:all_hits].positive?
        puts "Result: #{'+' * guess_result[:exact_hits]} #{'-' * guess_result[:part_hits]}\n\n"
      else
        puts "Result: *no matches*\n\n"
      end
      guess_result[:exact_hits] == 4 ? win : print_turns
      lose if @current_menu != :after_game_menu && @game.instance_variable_get(:@turns).zero?
    end

    def win
      @current_menu = :after_game_menu
      puts @win_msg
      save_result
    end

    def lose
      @current_menu = :after_game_menu
      puts @lose_msg
    end

    def save_result?
      puts 'Do you want to save your result?(y/n)'
      save = Readline.readline('>>> ')
      save == 'y'
    end

    def save_result
      if save_result?
        puts 'Enter your name:'
        player_name = Readline.readline('>>> ')
        result_arr = [player_name, Date.today, 10 - @game.instance_variable_get(:@turns)]
        write_result_to_file(result_arr)
        puts "Result saved\n\n"
      else
        puts "Result is not saved\n\n"
      end
    end

    def write_result_to_file(result_arr)
      prev_results = YAML.load_file('lib/rg_hw_codebreaker/results.yml')
      prev_results << result_arr
      File.open('lib/rg_hw_codebreaker/results.yml', 'w') do |file|
        YAML.dump(prev_results, file)
      end
    end

    def hint
      @game.give_a_hint
    end

    def best_results
      @current_menu = :short_menu
      puts "BEST RESULTS\n\n"
      best_results = YAML.load_file('lib/rg_hw_codebreaker/results.yml')
      best_results.each do |result_record|
        result_record.each { |col| print col.to_s.ljust(15) }
        puts "\n"
      end
      puts "\n"
      print_menu
    end

    def help
      @current_menu = :short_menu
      puts @help_msg
      print_menu
    end

    def go_to_main_menu
      @current_menu = :main_menu
      greet
      print_menu
    end
  end
end
