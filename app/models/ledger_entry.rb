class LedgerEntry
    attr_reader :user_id, :type, :key, :metadata, :created_at
    def initialize(user_id:, type:, key:, metadata: {}, created_at: Time.now)
        @user_id, @type, @key, @metadata, @created_at = user_id, type, key, metadata, created_at
    end
end

