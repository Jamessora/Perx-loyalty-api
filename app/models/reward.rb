class Reward
    attr_reader :code, :label
    def initialize(code:, label:)
        @code, @label = code, label
    end
end

