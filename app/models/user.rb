class User
    attr_reader :id, :name, :birthday_month
    def initialize(id:, name:, birthday_month:)
        @id = id
        @name = name
        @birthday_month = Integer(birthday_month)
    end
end

