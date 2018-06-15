module RgHwCodebreaker
  # Class Game responsible for game mechanics
  class Game
    attr_reader :turns

    def initialize
      @turns = 10
      @hints = 1
      @code = []
    end

    def start
      4.times { @code << rand(1..6).to_s }
    end

    def check_guess(guess)
      @turns -= 1
      all_hits = guess.chars.count { |digit| @code.include?(digit) }
      exact_hits = (guess.chars.each_with_index.to_a & @code.each_with_index.to_a).size
      part_hits = all_hits - exact_hits
      { all_hits: all_hits, exact_hits: exact_hits, part_hits: part_hits }
    end

    def any_hints_left?
      @hints.zero? ? false : true
    end

    def give_a_hint
      @hints -= 1
      @code[0]
    end
  end
end
