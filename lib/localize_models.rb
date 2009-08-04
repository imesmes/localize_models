# LocalizeModels
%w{ models }.each do |dir| 
  path = File.join(File.dirname(__FILE__), 'app', dir)  
  $LOAD_PATH << path 
  ActiveSupport::Dependencies.load_paths << path 
  ActiveSupport::Dependencies.load_once_paths.delete(path) 
end

Dir.glob(File.join(File.dirname(__FILE__), "db", "migrate", "*")).each do |file| 
  require file 
end

class ActiveRecord::Base
  class << self    
    def localize(*attribute_names)
      attribute_names.each do |attribute_name|
        type = self.columns_hash["#{attribute_name}"].type
        languages = Language.all.delete_if { |l| l[:code] == I18n.default_locale.to_s }
        class_eval %{
          def #{attribute_name}_#{I18n.default_locale.to_s}
            #{attribute_name}
          end

          def #{attribute_name}_#{I18n.default_locale.to_s}=(param)
            #{attribute_name}=(param)
          end
        }
        languages.each do |language|
          class_eval %{
            def #{attribute_name}_#{language.code}
              if @localize_#{type.to_s}.nil?
                @localize_#{type.to_s} = {}
                @localize_#{type.to_s}[:#{attribute_name}] = {}
              end
              if @localize_#{type.to_s}[:#{attribute_name}][:#{language.code}].nil?
                language = Language.find_by_code(:#{language.code}.to_s)
                localize_model = LocalizeModel.find(:first, :conditions => 
                  {:model_name => self.class.name, :method_name => :#{attribute_name}.to_s, 
                  :object_id => self.id})
                if localize_model.nil?
                  @localize_#{type.to_s}[:#{attribute_name}][:#{language.code}] = nil
                else
                  localize_#{type.to_s} = Localize#{type.to_s.capitalize}.find(:first, :conditions => 
                    {:localize_model_id => localize_model.id, :language_id => language.id})
                  if localize_#{type.to_s}.nil?
                    @localize_#{type.to_s}[:#{attribute_name}][:#{language.code}] = nil
                  else
                    @localize_#{type.to_s}[:#{attribute_name}][:#{language.code}] = localize_#{type.to_s}.translation
                  end
                end
              end             
            end

            def #{attribute_name}_#{language.code}=(value)
              if @localize_#{type.to_s}.nil?
                @localize_#{type.to_s} = {}
                @localize_#{type.to_s}[:#{attribute_name}] = {}
              end
              @localize_#{type.to_s}[:#{attribute_name}][:#{language.code}] = value
            end
          }
        end
       end

       class_eval %{      
         after_save :save_localize

         def save_localize
           unless @localize_string.nil?
             @localize_string.each do |method,languages|
               localize_model = LocalizeModel.find(:first, :conditions => 
                   {:model_name => self.class.name, :method_name => method.to_s, :object_id => self.id})
               languages.each do |language,value|
                 language = Language.find_by_code(language.to_s)

                 if localize_model.nil?
                   localize_model = LocalizeModel.create(
                     :model_name => self.class.name, :method_name => method.to_s, :object_id => self.id)
                   LocalizeString.create(
                     :localize_model_id => localize_model.id, :language_id => language.id,
                     :translation => value)
                 else
                   localize_string = LocalizeString.find(:first, :conditions => 
                     {:localize_model_id => localize_model.id, :language_id => language.id})
                   if localize_string.nil?
                     LocalizeString.create(
                       :localize_model_id => localize_model.id, :language_id => language.id,
                       :translation => value)
                   else
                     localize_string.translation = value
                     localize_string.save 
                   end
                 end
               end
             end
           end
        
           unless @localize_text.nil?
             @localize_text.each do |method,languages|
               localize_model = LocalizeModel.find(:first, :conditions => 
                   {:model_name => self.class.name, :method_name => method.to_s, :object_id => self.id})
               languages.each do |language,value|
                 language = Language.find_by_code(language.to_s)

                 if localize_model.nil?
                   localize_model = LocalizeModel.create(
                     :model_name => self.class.name, :method_name => method.to_s, :object_id => self.id)
                   LocalizeText.create(
                     :localize_model_id => localize_model.id, :language_id => language.id,
                     :translation => value)
                 else
                   localize_text = LocalizeText.find(:first, :conditions => 
                     {:localize_model_id => localize_model.id, :language_id => language.id})
                   if localize_text.nil?
                     LocalizeText.create(
                       :localize_model_id => localize_model.id, :language_id => language.id,
                       :translation => value)
                   else
                     localize_text.translation = value
                     localize_text.save 
                   end
                 end
               end
             end
           end
         end
       }
    end
  end
end
