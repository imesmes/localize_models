ActiveRecord::Schema.define(:version => 0) do
  create_table :dummy_articles, :force => true do |t|
    t.string  :title
    t.text    :description
  end
end 
