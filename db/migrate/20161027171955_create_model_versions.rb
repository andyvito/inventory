class CreateModelVersions < ActiveRecord::Migration
  def change
    create_table :model_versions do |t|
      t.integer :version
      t.date :new_date
      t.text :author
      t.text :comments
      t.timestamps null: false
      t.references :model_object, foreign_key: true
    end
  end
end
