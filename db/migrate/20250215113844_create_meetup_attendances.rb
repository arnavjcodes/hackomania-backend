class CreateMeetupAttendances < ActiveRecord::Migration[7.0]
  def change
    create_table :meetup_attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true  # This is our Meetup

      t.timestamps
    end

    # Ensure a user can join a meetup only once.
    add_index :meetup_attendances, [ :user_id, :event_id ], unique: true
  end
end
