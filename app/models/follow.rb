# app/models/follow.rb
class Follow < ApplicationRecord
    belongs_to :follower, class_name: 'User'
    belongs_to :followed_user, class_name: 'User'
  
    validates :follower_id, uniqueness: { scope: :followed_user_id }
    validate :cannot_follow_self
  
    private
  
    def cannot_follow_self
      errors.add(:followed_user, "can't follow yourself") if follower_id == followed_user_id
    end
  end