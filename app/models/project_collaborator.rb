# app/models/project_collaborator.rb
class ProjectCollaborator < ApplicationRecord
  belongs_to :project
  belongs_to :user

  # You might add validations to ensure a user isn’t added twice
  validates :user_id, uniqueness: { scope: :project_id }
end
