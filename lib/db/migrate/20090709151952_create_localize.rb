class CreateLocalize < ActiveRecord::Migration
  def self.up
    create_table :localize_models do |t|
      t.integer :object_id
      t.string :model_name
      t.string :method_name
    end

    create_table :localize_strings do |t|
      t.integer :localize_model_id
      t.integer :language_id
      t.string :translation
    end

    create_table :localize_texts do |t|
      t.integer :localize_model_id
      t.integer :language_id
      t.text :translation
    end
  end

  def self.down
    drop_table :localize_models
    drop_table :localize_strings
    drop_table :localize_texts
  end
end
