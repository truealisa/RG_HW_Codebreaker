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
      let(:guess) { '1234' }

      before do
        # subject.check_guess(guess)
      end

      it 'decreases number of left turns by 1' do
        expect { subject.check_guess(guess) }.to change { subject.turns }.from(10).to(9)
      end

      it 'returns hash with matches' do
        expect(subject.check_guess(guess)).to include(all_hits: kind_of(Numeric), 
                                                      exact_hits: kind_of(Numeric), 
                                                      part_hits: kind_of(Numeric))
      end
    end

    describe '#give_a_hint' do
      before do
        subject.start
      end

      context 'no hints left' do
        before { subject.instance_variable_set(:@hints, 0) }

        specify { expect { subject.give_a_hint }.to output("No hints left :(\n").to_stdout }
      end

      context 'some hints left' do
        it 'prints hint to console' do
          expect { subject.give_a_hint }.to output(
            "Hint: #{subject.instance_variable_get(:@code)[0]}xxx\n\n").to_stdout
        end

        it 'decreases number of left hints by 1' do
          expect { subject.give_a_hint }.to change {
            subject.instance_variable_get(:@hints)
          }.from(1).to(0)
        end
      end
    end
  end
end
