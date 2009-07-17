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
        Language.all.each do |language|
          class_eval %{
            def #{attribute_name}_#{language.code}
              case self.class.columns_hash["#{attribute_name}"].type
                when :string
                  if @localize_strings.nil?
                    @localize_strings = {}
                    @localize_strings[:#{attribute_name}] = {}
                  end
                  if @localize_strings[:#{attribute_name}][:#{language.code}].nil?
                    language = Language.find_by_code(:#{language.code}.to_s)
                    localize_model = LocalizeModel.find(:first, :conditions => 
                      {:model_name => self.class.name, :method_name => :#{attribute_name}.to_s, 
                      :object_id => self.id})
                    if localize_model.nil?
                      @localize_strings[:#{attribute_name}][:#{language.code}] = ''
                    else
                      localize_string = LocalizeString.find(:first, :conditions => 
                        {:localize_model_id => localize_model.id, :language_id => language.id})
                      if localize_string.nil?
                        @localize_strings[:#{attribute_name}][:#{language.code}] = ''
                      else
                        @localize_strings[:#{attribute_name}][:#{language.code}] = localize_string.translation
                      end
                    end
                  end
                  @localize_strings[:#{attribute_name}][:#{language.code}]
                when :text
                  if @localize_texts.nil?
                    #implementar cerca                    
                  end
                  @localize_texts[:#{attribute_name}][:#{language.code}]
                else
                  raise "Type not supported yet."
              end              
            end

            def #{attribute_name}_#{language.code}=(value)
              case self.class.columns_hash["#{attribute_name}"].type
                when :string
                  if @localize_strings.nil?
                    @localize_strings = {}
                    @localize_strings[:#{attribute_name}] = {}
                  end
                  @localize_strings[:#{attribute_name}][:#{language.code}] = value
                when :text
                  if @localize_texts.nil?
                    @localize_texts = {}
                    @localize_texts[:#{attribute_name}] = {}
                  end
                  @localize_texts[:#{attribute_name}][:#{language.code}] = value
                else
                  raise "Type not supported yet."
              end              
            end
          }
        end
       end

       class_eval %{      
         after_save :save_localize

         def save_localize
           unless @localize_strings.nil?
             @localize_strings.each do |method,languages|
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
        
           unless @localize_texts.nil?
             @localize_texts.each do |method,languages|   
               languages.each do |language,value|
                 
               end               
             end
           end
         end
       }
    end
  end
end
