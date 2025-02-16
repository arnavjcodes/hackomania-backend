# app/models/project.rb
class Project < ApplicationRecord
  belongs_to :user

  # Collaborators join model (users other than the owner)
  has_many :project_collaborators, dependent: :destroy
  has_many :collaborators, through: :project_collaborators, source: :user

  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, presence: true

  # Optional fields:
  # - tech_stack: a comma-separated string listing technologies (e.g., "Ruby, Rails, React")
  # - schema_url: a URL to an image or PDF of the project schema
  # - flowchart_url: a URL to an image or PDF of the project flowchart
end
