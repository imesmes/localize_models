ActiveRecord::Schema.define(:version => 0) do
  create_table :dummy_articles, :force => true do |t|
    t.string  :title
    t.text    :description
  end

  create_table :languages, :force => true do |t|
    t.string :name
    t.string :code
  end

  Language.create :name => 'Catalan', :code => 'ca'
  Language.create :name => 'Spanish', :code => 'es'

  create_table :localize_models, :force => true do |t|
    t.integer :object_id
    t.string  :model_name
    t.string  :method_name
  end

  create_table :localize_strings, :force => true do |t|
    t.integer :localize_model_id
    t.integer :language_id
    t.string  :translation
  end

  create_table :localize_texts, :force => true do |t|
    t.integer :localize_model_id
    t.integer :language_id
    t.text    :translation
  end

end 
