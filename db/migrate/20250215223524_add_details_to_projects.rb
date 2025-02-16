class AddDetailsToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :tech_stack, :string    # e.g., "Ruby, Rails, React"
    add_column :projects, :schema_url, :string      # URL or path to a schema image/PDF
    add_column :projects, :flowchart_url, :string   # URL or path to a flowchart image/PDF
  end
end
