require 'spec_helper'

module RgHwCodebreaker
  RSpec.describe Game do
    describe '#start' do
      let(:game) { Game.new }
      let(:code) { game.instance_variable_get(:@code) }

      before :each do
        game.start
      end

      it 'generates 4 numbers secret code' do
        expect(code.size).to eq(4)
      end
      it 'generates secret code with numbers from 1 to 6' do
        expect(code).to all(match(/\A[1-6]\z/))
      end
    end

    describe '#check_guess' do
      it 'decrease amount of turns by one'
      it 'counts all appearences of each guessed digit in a secret code'
    end
  end
end
