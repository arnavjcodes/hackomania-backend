class MeetupAttendance < ApplicationRecord
  belongs_to :user
  belongs_to :event  # Our Meetup
end
