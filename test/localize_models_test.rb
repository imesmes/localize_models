require File.dirname(__FILE__) + '/test_helper.rb' 

class LocalizeModelsTest < ActiveSupport::TestCase
  load_schema

  class DummyArticle < ActiveRecord::Base
  end

  def test_schema_has_loaded_correctly
    assert_equal [], DummyArticle.all
  end
end
