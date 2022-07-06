class Game
    def initialize
        @codebreaker = nil
        @codemaker = nil
        @code = []
        @guess = []
        @guess_count = 0
        @feedback = []
    end
  
    def get_code
        @code = @codemaker.set_code
    end
  
    def get_guess
        if @codebreaker.class == ComputerPlayer
        @guess = @codebreaker.make_guess(@feedback,@guess)
    else
        @guess = @codebreaker.make_guess
    end
        @guess_count += 1
        print "Guess => #{@guess}"
    end
  
    def give_feedback
        @feedback = []
        guess_checked = [false,false,false,false]
        code_checked = [false,false,false,false]
        for i in 0..3 do
            if @guess[i] == @code[i]
                @feedback.push("[R]")
                guess_checked[i] = true
                code_checked[i] = true
            end
        end
        
        for i in 0..3 do
            if guess_checked[i]
                next
            end
            for j in 0..3 do
                if (@guess[i] == @code[j]) && (code_checked[j] == false)
                    @feedback.push("[W]")
                    code_checked[j] = true
                    guess_checked[i] = true
                    break
                end
            end
        end
        
        while @feedback.length < 4
            @feedback.push("[ ]")
        end
        return @feedback
    end
  
    def check_winner
        if cracked?
            puts "\nThe codebreaker wins!"
            return true
        elsif out_of_turns?
            puts "\nThe codemaker wins!"
            puts "\nThe code was #{@code}"
            return true
        else
            return false
        end
    end
  
    def cracked?
        return (@feedback[0] == "[R]" && @feedback[1] == "[R]" && @feedback[2] == "[R]" && @feedback[3] == "[R]")
    end
  
    def out_of_turns?
        return @guess_count == 12
    end
  
    def set_game_mode
        mode = gets.chomp.upcase
        while (mode != "CM" && mode != "CB")
            mode = gets.chomp.upcase
        end
        return mode
    end
  
    def create_players(mode)
        if (mode == "CM")
            @codebreaker = ComputerPlayer.new()
            @codemaker = HumanPlayer.new()
        else
            @codemaker = ComputerPlayer.new()
            @codebreaker = HumanPlayer.new()
        end
    end
  
    def self.pattern_valid?(pattern)
        if pattern.length > 5
            return false
        end
        for i in 0..3
            if (pattern[i] != "R" && pattern[i] != "G" && pattern[i] != "B" && pattern[i] != "Y" && pattern[i] != "M" && pattern[i] != "C")
                return false
            end
        end
        return true
    end
  
    def play
        puts "Welcome to Mastermind"
        puts "\nThis game is played by 2 players (a CodeMaker and a CodeBreaker)\nThe CodeMaker thinks a 4 colors code using any combination and the CodeBreaker has 12 turns to guess it.\nAfter each guess the CodeBreaker receives a feedback on how good his guess was"
        puts "\nThe color options are:\nRed (r)\nGreen (g)\nBlue (b)\nCyan (c)\nMagenta (m)\nYellow (y)"
        puts "\nFeedback pegs:\n[R] => Right color in the right position\n[W] => Right color in the wrong position\n[ ] => Not the right color"
        print "\nDo you want to be CodeMaker(cm) or CodeBreaker(cb)?"
        mode = self.set_game_mode
        self.create_players(mode)
        self.get_code
        while !self.check_winner
            puts "\nTurn ##{@guess_count+1}"
            self.get_guess
            puts " || Feedback => #{self.give_feedback}"
        end
    end
end
  
class HumanPlayer
    def initialize
    end
    def set_code
        code = []
        puts "Enter your 4 colors pattern. Example(rgby)"
        colors = gets.upcase.split("")
        while !Game.pattern_valid?(colors)
            colors = gets.upcase.split("")
        end 
        for i in 0..3
            case colors[i]
            when "R"
                code[i] = "[R]"
            when "G"
                code[i] = "[G]"
            when "B"
                code[i] = "[B]"
            when "C"
                code[i] = "[C]"
            when "M"
                code[i] = "[M]"
            when "Y"
                code[i] = "[Y]" 
            else
                code[i] = nil
            end
        end
        return code
    end
  
    def make_guess
        guess = []
        print "Make your guess. Example(rgby): "
        colors = gets.upcase.split("")
        while !Game.pattern_valid?(colors)
            colors = gets.upcase.split("")
        end 
        for i in 0..3 do
            case colors[i]
            when "R"
                guess[i] = "[R]"
            when "G"
                guess[i] = "[G]"
            when "B"
                guess[i] = "[B]"
            when "C"
                guess[i] = "[C]"
            when "M"
                guess[i] = "[M]"
            when "Y"
                guess[i] = "[Y]" 
            else
                guess[i] = nil
            end 
        end
        return guess
    end
end
  
class ComputerPlayer
    def initialize
        @solutions = ["[R]", "[G]", "[B]", "[Y]", "[M]", "[C]"].repeated_permutation(4).to_a
        @first_guess = true
    end
    
    def set_code
        puts "\nThe computer is generating a code..."
        sleep 1
        code = []
        for i in 0..3 do
            code[i] = ["[R]", "[G]", "[B]", "[C]", "[M]", "[Y]"][rand(6)]
        end
        return code
    end
  
    def purge_solutions(feedback,current_guess)
        @solutions.delete_if {|pattern|
            get_feedback(pattern,current_guess) != feedback
        }
    end
  
    def get_feedback(current_guess,code)
        feedback = []
        guess_checked = [false,false,false,false]
        code_checked = [false,false,false,false]
        for i in 0..3 do
            if current_guess[i] == code[i]
                feedback.push("[R]")
                guess_checked[i] = true
                code_checked[i] = true
            end
        end
        for i in 0..3 do
            if guess_checked[i]
                next
            end
        for j in 0..3 do
            if (current_guess[i] == code[j]) && (code_checked[j] == false)
                feedback.push("[W]")
                code_checked[j] = true
                guess_checked[i] = true
                break
            end
        end
    end
        while (feedback.length < 4)
            feedback.push("[ ]")
        end
        return feedback
    end
  
    def calculate_scores
        possible_guesses = []
        high_score = 0
        feedback_combinations = ["[R]","[W]","[ ]"].repeated_combination(4).to_a
        feedback_combinations.delete(["[R]","[R]","[R]","[W]"])
        @solutions.each {|pattern1|
        pattern_score = 1296
        for i in 0...feedback_combinations.length
            current_score = 0
            @solutions.each {|pattern2|
            if get_feedback(pattern1,pattern2) != feedback_combinations[i]
                current_score += 1
            end
        }
        if current_score < pattern_score
            pattern_score = current_score
            end 
        end
        if pattern_score > high_score
            high_score = pattern_score
            possible_guesses = []
            possible_guesses.push(pattern1)
        elsif pattern_score == high_score
            possible_guesses.push(pattern1)
        end
    }
    return possible_guesses
end
  
    def make_guess(feedback,current_guess)
        puts "\nThe computer is thinking..."
        sleep 2
        if @first_guess
            current_guess = ["[R]","[R]","[G]","[G]"]
            @first_guess = false
            return current_guess
        end
        purge_solutions(feedback,current_guess)
        possible_guesses = calculate_scores()
        current_guess = possible_guesses[0]
        return current_guess
    end
end
  
Game.new.play