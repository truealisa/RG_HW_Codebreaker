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
          expect(subject).to receive(:exit?).once
          subject.repl
        end
      end

      context 'non-exit option has been chosen' do
        before do
          allow(subject).to receive(:exit?).and_return(false, false)
          allow(Readline).to receive(:readline).and_return('user input')
        end

        it 'continues to loop' do
          expect(subject).to receive(:exit?).exactly(:twice)
          subject.repl
        end

        it 'catches input with readline' do
          expect(Readline).to receive(:readline).exactly(:twice)
          subject.repl
        end

        it 'handles input' do
          expect(subject).to receive(:handle_input).with('user input').exactly(:twice)
          subject.repl
        end
      end
    end

    describe '#exit?' do
      context 'instance variable @exit_break is falsey' do
        it 'returns false' do
          expect(subject.exit?).to be_falsey
        end
      end

      context 'instance variable @exit_break is truthy' do
        it 'returns true' do
          subject.instance_variable_set(:@exit_break, true)
          expect(subject.exit?).to be_truthy
        end
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
          expect(subject).to receive(:detect_selected).with(kind_of(String)).exactly(:once)
          subject.handle_input(input)
        end

        context 'input is invalid' do
          let(:input) { 'invalid input' }

          it "calls 'invalid_selection' method" do
            expect(subject).to receive(:invalid_selection).exactly(:once)
            subject.handle_input(input)
          end
        end

        context 'input is valid' do
          let(:input) { '1' }

          it 'evalutes selected option' do
            expect(subject).to receive(:eval).with(kind_of(String)).exactly(:once)
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
              .exactly(:once).and_return(kind_of(Symbol))
            subject.detect_selected(input)
          end
        end

        context 'last menu item has been chosen' do
          let(:current_menu) { :main_menu }
          let(:input) { Cli::MENU[current_menu].size.to_s }

          it 'returns corresponding menu item' do
            expect(subject).to receive(:detect_selected).with(kind_of(String))
              .exactly(:once).and_return(kind_of(Symbol))
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
              .exactly(:once).and_return(false)
            subject.detect_selected(input)
          end
        end

        context 'invalid input has been entered' do
          let(:input) { 'invalid input' }

          it 'returns false' do
            expect(subject).to receive(:detect_selected).with(kind_of(String))
              .exactly(:once).and_return(false)
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
        expect(subject).to receive(:print_current_menu).exactly(:once)
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
        expect(subject.instance_variable_get(:@game)).to be_a Game
      end

      it 'starts game' do
        expect_any_instance_of(Game).to receive(:start)
        subject.start_game
      end

      it 'prints game message to console' do
        expect($stdout.string).to include(Cli::GAME_MSG)
      end

      it 'prints turns counter' do
        expect(subject).to receive(:print_turns).exactly(:once)
        subject.start_game
      end

      it 'shows current menu options' do
        expect(subject).to receive(:print_current_menu).exactly(:once)
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
        expect($stdout.string).to end_with("Turns left: #{subject
          .instance_variable_get(:@game).turns}\n\n")
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
        expect(subject).to receive(:valid_guess?).with(kind_of(String))
        subject.submit_guess
      end

      context 'valid guess has been entered' do
        before do
          allow(Readline).to receive(:readline).and_return('1111')
          allow(subject).to receive(:handle_guess_result)
        end

        it 'checkes guess for matches' do
          expect(subject.instance_variable_get(:@game)).to receive(:check_guess)
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
        expect(subject).to receive(:print_current_menu).exactly(:once)
        subject.submit_guess
      end
    end

    describe '#valid_guess?' do
      context 'guess is valid (contains 4 digits in the range from 1 to 6)' do
        let(:guess) { '1256' }

        it 'returns true' do
          expect(subject.valid_guess?(guess)).to be true
        end
      end

      context 'guess in invalid' do
        context 'guess contains more than 4 digits' do
          let(:guess) { '12345' }

          it 'returns false' do
            expect(subject.valid_guess?(guess)).to be false
          end
        end

        context "guess contains '0'" do
          let(:guess) { '0123' }

          it 'returns false' do
            expect(subject.valid_guess?(guess)).to be false
          end
        end

        context "guess contains '7'" do
          let(:guess) { '1237' }

          it 'returns false' do
            expect(subject.valid_guess?(guess)).to be false
          end
        end

        context "guess contains non-digit chars" do
          let(:guess) { '123o' }

          it 'returns false' do
            expect(subject.valid_guess?(guess)).to be false
          end
        end
      end
    end

    describe '#handle_guess_result' do
      
    end
  end
end
