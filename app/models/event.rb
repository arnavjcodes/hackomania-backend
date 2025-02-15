class Event < ApplicationRecord
  belongs_to :user  # Organizer

  # Attendance associations
  has_many :meetup_attendances, dependent: :destroy
  has_many :attendees, through: :meetup_attendances, source: :user

  # Existing validations and scopes...
  validates :title, presence: true
  validates :start_time, presence: true
  validates :event_type, inclusion: { in: %w[physical online hybrid] }

  # For physical events, ensure a location is provided.
  validate :location_presence_for_physical_event

  scope :upcoming, -> { where("start_time >= ?", Time.current).order(start_time: :asc) }

  private

  def location_presence_for_physical_event
    if event_type == "physical" && location.blank?
      errors.add(:location, "must be provided for physical events")
    end
  end
end
