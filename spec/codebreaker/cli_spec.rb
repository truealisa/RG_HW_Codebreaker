require 'spec_helper'

module RgHwCodebreaker
  RSpec.describe Cli do
    describe '#run' do
      before do
        allow(subject).to receive(:repl)
      end

      it 'greets user' do
        expect(subject).to receive(:greet)
        subject.run
      end

      it 'shows start menu options' do
        expect(subject).to receive(:print_current_menu)
        subject.run
      end

      it 'starts read-eval-print loop' do
        expect(subject).to receive(:repl)
        subject.run
      end
    end

    describe '#greet' do
      it 'prints to console greeting message' do
        expect { subject.greet }.to output(Cli::WELCOME_MSG).to_stdout
      end
    end

    describe '#print_current_menu' do
      context 'in main menu' do
        before do
          subject.print_current_menu
        end

        it 'prints to console main menu options' do
          Cli::MENU[:main_menu].each do |menu_item|
            expect($stdout.string).to include(menu_item.gsub(/[_]/, ' ').capitalize)
          end
        end

        it 'prints to console exit option' do
          expect($stdout.string).to include('0 - Exit')
        end
      end

      context 'in in-game menu' do
        before do
          subject.instance_variable_set(:@current_menu, :in_game_menu)
          subject.print_current_menu
        end

        it 'prints to console in-game menu options' do
          Cli::MENU[:in_game_menu].each do |menu_item|
            expect($stdout.string).to include(menu_item.gsub(/[_]/, ' ').capitalize)
          end
        end

        it 'prints to console exit option' do
          expect($stdout.string).to include('0 - Exit')
        end
      end

      context 'in after-game menu' do
        before do
          subject.instance_variable_set(:@current_menu, :after_game_menu)
          subject.print_current_menu
        end

        it 'prints to console after-game menu options' do
          Cli::MENU[:after_game_menu].each do |menu_item|
            expect($stdout.string).to include(menu_item.gsub(/[_]/, ' ').capitalize)
          end
        end

        it 'prints to console exit option' do
          expect($stdout.string).to include('0 - Exit')
        end
      end

      context 'in short menu' do
        before do
          subject.instance_variable_set(:@current_menu, :short_menu)
          subject.print_current_menu
        end

        it 'prints to console short menu options' do
          Cli::MENU[:short_menu].each do |menu_item|
            expect($stdout.string).to include(menu_item.gsub(/[_]/, ' ').capitalize)
          end
        end

        it 'prints to console exit option' do
          expect($stdout.string).to include('0 - Exit')
        end
      end
    end

    describe '#repl' do
      before do
        allow(subject).to receive(:loop).and_yield.and_yield
      end

      context 'exit option has been chosen' do
        before do
          allow(subject).to receive(:exit?) { true }
        end

        it 'breaks the loop' do
          expect(subject).to receive(:exit?)
          subject.repl
        end
      end

      context 'non-exit option has been chosen' do
        before do
          allow(subject).to receive(:exit?).and_return(false, false)
          allow(Readline).to receive(:readline).and_return('user input')
        end

        it 'continues to loop' do
          expect(subject).to receive(:exit?).twice
          subject.repl
        end

        it 'catches input with readline' do
          expect(Readline).to receive(:readline).twice
          subject.repl
        end

        it 'handles input' do
          expect(subject).to receive(:handle_input).with('user input').twice
          subject.repl
        end
      end
    end

    describe '#exit?' do
      context 'instance variable @exit_break is false' do
        specify { expect(subject.exit?).to be false }
      end

      context 'instance variable @exit_break is true' do
        before do
          subject.instance_variable_set(:@exit_break, true)
        end

        specify { expect(subject.exit?).to be true }
      end
    end

    describe '#handle_input' do
      context "input == '0' (exit option)" do
        let(:input) { '0' }

        before do
          subject.handle_input(input)
        end

        it 'sets @exit_break variable to true' do
          expect(subject.instance_variable_get(:@exit_break)).to be true
        end
      end

      context 'input != 0' do
        let(:input) { 'some input' }

        it 'detects selected menu item from input' do
          expect(subject).to receive(:detect_selected).with(kind_of(String))
          subject.handle_input(input)
        end

        context 'input is invalid' do
          let(:input) { 'invalid input' }

          it "calls '#invalid_selection' method" do
            expect(subject).to receive(:invalid_selection)
            subject.handle_input(input)
          end
        end

        context 'input is valid' do
          let(:input) { '1' }

          it 'evalutes selected option' do
            expect(subject).to receive(:eval).with(kind_of(String))
            subject.handle_input(input)
          end
        end
      end
    end

    describe '#detect_selected' do
      context 'input corresponds to one of menu items' do
        context 'first menu item has been chosen' do
          let(:input) { '1' }

          it 'returns corresponding menu item' do
            expect(subject).to receive(:detect_selected).with(kind_of(String))
              .and_return(kind_of(Symbol))
            subject.detect_selected(input)
          end
        end

        context 'last menu item has been chosen' do
          let(:current_menu) { :main_menu }
          let(:input) { Cli::MENU[current_menu].size.to_s }

          it 'returns corresponding menu item' do
            expect(subject).to receive(:detect_selected).with(kind_of(String))
              .and_return(kind_of(Symbol))
            subject.detect_selected(input)
          end
        end
      end

      context 'input does not correspond to any menu item' do
        context 'number bigger then menu size has been chosen' do
          let(:current_menu) { :main_menu }
          let(:input) { (Cli::MENU[current_menu].size + 1).to_s }

          it 'returns false' do
            expect(subject).to receive(:detect_selected).with(kind_of(String))
              .and_return(false)
            subject.detect_selected(input)
          end
        end

        context 'invalid input has been entered' do
          let(:input) { 'invalid input' }

          it 'returns false' do
            expect(subject).to receive(:detect_selected).with(kind_of(String))
              .and_return(false)
            subject.detect_selected(input)
          end
        end
      end
    end

    describe '#invalid_selection' do
      it 'prints to console warning message about invalid selection' do
        subject.invalid_selection
        expect($stdout.string).to include(Cli::INVALID_MSG)
      end

      it 'shows current menu options' do
        expect(subject).to receive(:print_current_menu)
        subject.invalid_selection
      end
    end

    describe '#start_game' do
      before do
        subject.start_game
      end

      it 'switches current menu to in-game menu' do
        expect(subject.instance_variable_get(:@current_menu)).to eq(:in_game_menu)
      end

      it 'creates instance variable @game with new instance of Game' do
        expect(subject.game).to be_a Game
      end

      it 'starts game' do
        expect_any_instance_of(Game).to receive(:start)
        subject.start_game
      end

      it 'prints game message to console' do
        expect($stdout.string).to include(Cli::GAME_MSG)
      end

      it 'prints turns counter' do
        expect(subject).to receive(:print_turns)
        subject.start_game
      end

      it 'shows current menu options' do
        expect(subject).to receive(:print_current_menu)
        subject.start_game
      end
    end

    describe '#play_again' do
      it 'does the same things as #start_game' do
        expect(Cli.new.method(:play_again).original_name).to eq(Cli.new.method(:start_game)
          .original_name)
        expect(Cli.new.method(:play_again).source_location).to eq(Cli.new.method(:start_game)
          .source_location)
      end
    end

    describe '#print_turns' do
      before do
        subject.start_game
      end

      it 'prints to console message with the left turns number' do
        subject.print_turns
        expect($stdout.string).to end_with("Turns left: #{subject.game.turns}\n\n")
      end
    end

    describe '#submit_guess' do
      before do
        allow(Readline).to receive(:readline).and_return('user guess')
        subject.start_game
        subject.submit_guess
      end

      it 'offers user to input guess' do
        expect($stdout.string).to include('Your guess:')
      end

      it 'catches guess with readline' do
        expect(Readline).to receive(:readline)
        subject.submit_guess
      end

      it 'validates guess' do
        expect(subject.instance_variable_get(:@game)).to receive(:valid_guess?).with(kind_of(String))
        subject.submit_guess
      end

      context 'valid guess has been entered' do
        before do
          allow(Readline).to receive(:readline).and_return('1111')
          allow(subject).to receive(:handle_guess_result)
        end

        it 'checkes guess for matches' do
          expect(subject.game).to receive(:check_guess)
            .with(kind_of(String))
          subject.submit_guess
        end

        it 'handles guess result' do
          expect(subject).to receive(:handle_guess_result).with(kind_of(Hash))
          subject.submit_guess
        end
      end

      context 'invalid guess has been entered' do
        it 'prints to console message about invalid guess' do
          expect($stdout.string).to include("Your input is invalid!\n\n")
        end
      end

      it 'shows current menu options' do
        expect(subject).to receive(:print_current_menu)
        subject.submit_guess
      end
    end

    describe '#handle_guess_result' do
      before do
        allow(subject).to receive(:print_turns).at_least(:once)
      end

      context 'not winning guess' do
        let(:guess_result) { { all_hits: 2, exact_hits: 1, part_hits: 1 } }

        it 'prints turns counter' do
          expect(subject).to receive(:print_turns)
          subject.handle_guess_result(guess_result)
        end

        it 'checks left turns' do
          expect(subject).to receive(:no_turns_left?)
          subject.handle_guess_result(guess_result)
        end

        context 'guess contains no matches' do
          let(:guess_result) { { all_hits: 0, exact_hits: 0, part_hits: 0 } }

          before do
            subject.handle_guess_result(guess_result)
          end

          it 'reports about no matches to console' do
            expect($stdout.string).to include('Result: *no matches*')
          end
        end

        context 'guess contains some matches (2 - exact, 2 - part)' do
          let(:guess_result) { { all_hits: 4, exact_hits: 2, part_hits: 2 } }

          before do
            subject.handle_guess_result(guess_result)
          end

          it 'reports about exact matches to console' do
            expect($stdout.string).to include('+' * 2)
          end

          it 'reports about part matches to console' do
            expect($stdout.string).to include('-' * 2)
          end
        end

        context 'no turns left' do
          before do
            allow(subject).to receive(:no_turns_left?).and_return(true)
          end

          it "calls '#lose' method" do
            expect(subject).to receive(:lose)
            subject.handle_guess_result(guess_result)
          end
        end
      end

      context 'winning guess (4 exact matches)' do
        let(:guess_result) { { all_hits: 4, exact_hits: 4, part_hits: 0 } }

        before do
          allow(subject).to receive(:win)
          subject.handle_guess_result(guess_result)
        end

        it 'reports about matches to console' do
          expect($stdout.string).to include('+' * 4)
        end

        it "calls '#win' method" do
          expect(subject).to receive(:win)
          subject.handle_guess_result(guess_result)
        end
      end
    end

    describe '#no_turns_left?' do
      before do
        subject.start_game
      end

      context 'game is not finished yet and all turns are used' do
        before do
          allow(subject.game).to receive(:turns).and_return(0)
        end

        specify { expect(subject.no_turns_left?).to be true }
      end

      context 'all turns are used, but game is already finished (won)' do
        before do
          allow(subject.game).to receive(:turns).and_return(0)
          subject.instance_variable_set(:@current_menu, :after_game_menu)
        end

        specify { expect(subject.no_turns_left?).to be false }
      end

      context 'game is not finished yet and some turns are left' do
        specify { expect(subject.no_turns_left?).to be false }
      end
    end

    describe '#win' do
      before do
        allow(subject).to receive(:save_result)
        subject.win
      end

      it 'sets current menu to after-game menu' do
        expect(subject.instance_variable_get(:@current_menu)).to eq(:after_game_menu)
      end

      it 'prints winning message to console' do
        expect { subject.win }.to output(Cli::WIN_MSG).to_stdout
      end

      it "calls '#save_result' method" do
        expect(subject).to receive(:save_result)
        subject.win
      end
    end

    describe '#lose' do
      before do
        subject.lose
      end

      it 'sets current menu to after-game menu' do
        expect(subject.instance_variable_get(:@current_menu)).to eq(:after_game_menu)
      end

      it 'prints lose message to console' do
        expect { subject.lose }.to output(Cli::LOSE_MSG).to_stdout
      end
    end

    describe '#save_result' do
      context 'user wants to save result' do
        before do
          allow(subject).to receive(:save_result?).and_return(true)
          allow(Readline).to receive(:readline).and_return('username')
          allow(subject).to receive(:write_result_to_file).with(kind_of(Array))
          subject.start_game
          subject.save_result
        end

        it 'asks user to enter their name' do
          expect($stdout.string).to include('Enter your name:')
        end

        it 'gets entered username with readline' do
          expect(Readline).to receive(:readline)
          subject.save_result
        end

        it 'writes result to file' do
          expect(subject).to receive(:write_result_to_file)
            .with(array_including('username', Date.today, 10 - subject.game.turns))
          subject.save_result
        end

        it 'prints message about saving result to console' do
          expect($stdout.string).to include('Result was saved')
        end
      end

      context 'user does not want to save result' do
        before { allow(subject).to receive(:save_result?).and_return(false) }

        specify { expect { subject.save_result }.to output("Result was not saved\n\n").to_stdout }
      end
    end

    describe '#save_result?' do
      before do
        allow(Readline).to receive(:readline)
      end

      it 'asks user if they want to save result' do
        expect { subject.save_result? }.to output("Do you want to save your result?(y/n)\n").to_stdout
      end

      context 'user chose to save result' do
        before do
          allow(Readline).to receive(:readline).and_return('y')
        end

        specify { expect(subject.save_result?).to be true }
      end

      context 'user chose not to save result' do
        before do
          allow(Readline).to receive(:readline).and_return('n')
        end

        specify { expect(subject.save_result?).to be false }
      end

      context 'user entered anything else' do
        before do
          allow(Readline).to receive(:readline).and_return('abracadabra')
        end

        specify { expect(subject.save_result?).to be false }
      end
    end

    describe '#write_result_to_file' do
      let(:current_result) { ['test_username', Date.today, 5] }
      let(:results) { YAML.load_file('lib/rg_hw_codebreaker/results.yml') }

      after(:all) do
        result_file = YAML.load_file('lib/rg_hw_codebreaker/results.yml')
        result_file.slice!(-2, 2)
        File.open('lib/rg_hw_codebreaker/results.yml', 'w') do |file|
          YAML.dump(result_file, file)
        end
      end

      it 'rewrites results.yml with current result included' do
        subject.write_result_to_file(current_result)
        expect(results).to include(current_result)
      end

      it 'does not mutate previous results in the file' do
        previous_results = YAML.load_file('lib/rg_hw_codebreaker/results.yml')
        subject.write_result_to_file(current_result)
        previous_results.each do |result_record|
          expect(results).to include(result_record)
        end
      end
    end

    describe '#load_results_file' do
      it 'checks results file existance' do
        expect(File).to receive(:exist?)
        subject.load_results_file
      end

      context 'results file does not exist' do
        let(:results) { YAML.load_file('lib/rg_hw_codebreaker/results.yml') }

        before do
          allow(File).to receive(:exist?).and_return(false)
          subject.load_results_file
        end

        it 'creates new results file' do
          expect(YAML.load_file('lib/rg_hw_codebreaker/results.yml')).to be_truthy
        end

        it 'fills results file with heading line data' do
          expect(results).to include(%w[Player Date Turns])
        end
      end

      it 'returns results file' do
        expect(File).to receive(:read)
        subject.load_results_file
      end
    end

    describe '#hint' do
      before do
        subject.start_game
      end

      it 'checks if there any hints left' do
        expect(subject.game).to receive(:any_hints_left?)
        subject.hint
      end

      context 'some hints left' do
        it 'prints hint to console' do
          expect { subject.hint }.to output(
            "Hint: #{subject.game.instance_variable_get(:@code)[0]}xxx\n\n").to_stdout
        end
      end

      context 'no hints left' do
        before { subject.game.instance_variable_set(:@hints, 0) }

        specify { expect { subject.hint }.to output("No hints left :(\n\n").to_stdout }
      end
    end

    describe '#best_results' do
      let(:results) { YAML.load_file('lib/rg_hw_codebreaker/results.yml') }

      before do
        subject.best_results
      end

      it 'sets current menu to short menu' do
        expect(subject.instance_variable_get(:@current_menu)).to eq(:short_menu)
      end

      it 'prints to console header for best results' do
        expect($stdout.string).to include('BEST RESULTS')
      end

      it 'prints each result record from best results' do
        results.each do |result_record|
          expect($stdout.string).to match(%r{^#{result_record[0]}\s+#{result_record[1]}\s+#{result_record[2]}\s+$})
        end
      end

      it 'shows current menu options' do
        expect(subject).to receive(:print_current_menu)
        subject.best_results
      end
    end

    describe '#help' do
      before do
        subject.help
      end

      it 'sets current menu to short menu' do
        expect(subject.instance_variable_get(:@current_menu)).to eq(:short_menu)
      end

      it 'prints help message to console' do
        expect($stdout.string).to include(Cli::HELP_MSG)
      end

      it 'shows current menu options' do
        expect(subject).to receive(:print_current_menu)
        subject.help
      end
    end

    describe '#go_to_main_menu' do
      it 'sets current menu to main menu' do
        subject.help
        subject.go_to_main_menu
        expect(subject.instance_variable_get(:@current_menu)).to eq(:main_menu)
      end

      it 'greets user' do
        expect(subject).to receive(:greet)
        subject.go_to_main_menu
      end

      it 'shows main menu options' do
        expect(subject).to receive(:print_current_menu)
        subject.go_to_main_menu
      end
    end
  end
end
