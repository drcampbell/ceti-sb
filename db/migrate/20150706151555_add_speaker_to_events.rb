class AddSpeakerToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :speaker_id, :integer
  end
end
