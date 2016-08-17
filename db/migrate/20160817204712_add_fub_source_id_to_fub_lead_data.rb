class AddFubSourceIdToFubLeadData < ActiveRecord::Migration[5.0]
  def change
    add_column :fub_lead_data, :fub_source_id, :integer
  end
end
