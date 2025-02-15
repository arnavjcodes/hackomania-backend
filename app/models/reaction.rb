
class Reaction < ApplicationRecord
    belongs_to :user
    belongs_to :forum_thread
  
    # reaction_type in ["like", "chill"]
    validates :reaction_type, inclusion: { in: %w[like chill] }
    # unique constraint handled by DB index above
  end
  