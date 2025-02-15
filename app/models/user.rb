class User < ApplicationRecord
  has_many :reactions, dependent: :destroy
  validates :username, presence: true, uniqueness: true
  validates :email,
    uniqueness: { allow_blank: true },
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      allow_blank: true
    }

  # Relationships
  has_many :forum_threads, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :user_quiz_responses, dependent: :destroy
  has_many :cluster_assignments, dependent: :destroy

  has_many :events, dependent: :destroy
  # Preferences configuration
  store_accessor :preferences, :categories, :tags, :notifications
  before_save :set_default_preferences

  # Follow relationships
  has_many :follows_as_follower, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :follows_as_followed, class_name: "Follow", foreign_key: "followed_user_id", dependent: :destroy

  has_many :following, through: :follows_as_follower, source: :followed_user
  has_many :followers, through: :follows_as_followed, source: :follower


  def followers_count
    followers.count
  end

  def following_count
    following.count
  end

  def following?(user)
    following.include?(user)
  end

  private

  def set_default_preferences
    self.preferences ||= {
      categories: [],
      tags: [],
      notifications: {
        push: true
      }
    }
  end

  def current_cluster
    cluster_assignments.order(created_at: :desc).first&.cluster_id
  end

  def calculate_interests!
    responses = user_quiz_responses.joins(quiz_answer: :quiz_question)

    interest_weights = responses.each_with_object(Hash.new(0)) do |response, hash|
      response.quiz_answer.impact&.each do |interest, weight|
        hash[interest.to_s] += weight.to_f
      end
    end

    update(interests: interest_weights)
  end

  def similar_users
    current_cluster = current_cluster
    return User.none unless current_cluster

    User.joins(:cluster_assignments)
      .where(cluster_assignments: { cluster_id: current_cluster })
      .where.not(id: id)
  end
end
