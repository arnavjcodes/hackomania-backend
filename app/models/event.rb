class Event < ApplicationRecord
  belongs_to :user  # The organizer

  # Validations
  validates :title, presence: true
  validates :start_time, presence: true
  validates :event_type, inclusion: { in: %w[physical online hybrid] }

  # Optionally, if event is physical, ensure a location is provided.
  validate :location_presence_for_physical_event

  scope :upcoming, -> { where("start_time >= ?", Time.current).order(start_time: :asc) }

  private

  def location_presence_for_physical_event
    if event_type == "physical" && location.blank?
      errors.add(:location, "must be provided for physical events")
    end
  end
end
