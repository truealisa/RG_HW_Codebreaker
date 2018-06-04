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
        expect(code).to all(be_between(1, 6).inclusive)
      end
    end

    describe '#submit_guess' do
      it 'accept from user 4 numbers from 1 to 6'
      it 'compare user guess to secret code'
      it 'return result of comparison'
    end
  end
end
