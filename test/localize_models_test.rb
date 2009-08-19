require File.dirname(__FILE__) + '/test_helper.rb' 

class LocalizeModelsTest < Test::Unit::TestCase
  load_schema

  class DummyArticle < ActiveRecord::Base
    localize :title, :description
  end

  def test_schema_has_loaded_correctly
    assert_equal [], DummyArticle.all
  end

  def test_string_translation
    a1 = DummyArticle.new
    a1.title = 'This is english title'
    a1.title_es = 'This is spanish title'
    a1.save
    a2 = DummyArticle.find(a1.id)
    assert_equal a2.title, 'This is english title'
    assert_equal a2.title_es, 'This is spanish title'
    assert_nil a2.title_ca
  end

  def test_text_translation
    a1 = DummyArticle.new
    a1.description = "This is english description"
    a1.description_ca = "This is catalan description"
    a1.save
    a2 = DummyArticle.find(a1.id)
    assert_equal a2.description, "This is english description"
    assert_equal a2.description_ca, "This is catalan description"
    assert_nil a2.description_es
  end

  def test_purge
    a1 = DummyArticle.new
    a1.title = 'This is english title'
    a1.title_es = 'This is spanish title'
    a1.description = "This is english description"
    a1.description_ca = "This is catalan description"
    a1.save    
    a1.destroy
    assert_equal 0, DummyArticle.count
    assert_equal 0, LocalizeString.count
    assert_equal 0, LocalizeText.count
    assert_equal 0, LocalizeModel.count
  end
end
