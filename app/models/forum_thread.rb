class ForumThread < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :comments, as: :commentable, dependent: :destroy
  has_and_belongs_to_many :tags
  has_many :reactions, dependent: :destroy
  has_one :event, dependent: :nullify  # If a thread is deleted, you may want to keep or nullify the event reference.

  enum mood: {
    chill:      "Chill",
    excited:    "Excited",
    curious:    "Curious",
    supportive: "Supportive"
  }


  validates :title, presence: true, length: { maximum: 150 }
  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def like!
    increment!(:likes_count)
  end

  # Increments the chill_votes_count by 1
  def chillvote!
    increment!(:chill_votes_count)
  end
  # Getter for tag_list
  def tag_list
    tags.pluck(:name).join(", ")
  end

  def comments_count
    comments.count
  end

  # Setter for tag_list
  def tag_list=(tag_names)
    return if tag_names.blank?

    self.tags = tag_names.split(",").map do |tag_name|
      Tag.find_or_create_by(name: tag_name.strip)
    end
  end
end
