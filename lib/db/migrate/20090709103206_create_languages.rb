class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :name
      t.string :code
    end
    Language.create(:name => 'Català', :code => 'ca')
    Language.create(:name => 'Castellano', :code => 'es')
    Language.create(:name => 'English', :code => 'en')
  end

  def self.down
    drop_table :languages
  end
end
