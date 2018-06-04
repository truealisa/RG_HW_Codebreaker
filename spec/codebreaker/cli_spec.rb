require 'spec_helper'

module RgHwCodebreaker
  RSpec.describe Cli do
    describe '#run' do
      it 'greets user' do
        expect(subject).to receive(:greet)

        subject.run
      end
      it 'shows start menu options' do
        expect(subject).to receive(:print_menu)

        subject.run
      end
      it 'asks user for input'
      it 'captures user input'
      it 'handles user input'
    end
 
    describe '#greet' do
      it 'prints to console greeting message' do
        expect { subject.greet }.to output(Cli.instance_variable_get(:@welcome_msg))
          .to_stdout
      end
    end

    describe '#print_menu' do
      it 'prints to console menu options' do
        expect { subject.print_menu }.to output("1 - Start\n2 - Best results\n3 - Help\n0 - Exit\n\n")
          .to_stdout
      end
    end

    describe '#repl' do
      it 'gets user input' do

      end
      it 'validates user input'
      context 'if input is valid' do
        it 'procceds choosed option' do
          
        end
      end
      context 'if input is invalid' do
        it 'raises an error' do
          
        end
        it 'proposes to make choise again'
      end
    end
  end
end
