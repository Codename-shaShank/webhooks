class CreateNotes < ActiveRecord::Migration
  def change
    create_table(:notes) do |t|
      t.string :name
    end
  end
end