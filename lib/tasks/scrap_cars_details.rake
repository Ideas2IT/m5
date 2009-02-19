require 'rubygems'
require 'active_record'
require 'active_record/fixtures'



DATA_DIRECTORY = File.join(RAILS_ROOT, "lib", "tasks", "scrap")

namespace :scrap do
  desc "Scraping used cars details from the car wale site "   
  task :load_carwale_cars => :environment do
    used_cars = scrap_carwale_cars
    save_car_detail(used_cars)
  end
  
  desc "Scraping used cars details from the chennai car site"  
  task :load_click_in_cars => :environment do
    used_cars = scrap_click_in_used_cars
    save_car_detail(used_cars)
  end
  
  desc "Scraping used cars details from the clicked in site "   
  task :load_chennai_cars => :environment do
    used_cars = scrap_chennai_used_cars
    save_car_detail(used_cars)
  end
  
  desc "Scraping used cars details from the c"   
  task :load_autonagar_cars => :environment do
    used_cars = scrap_autonagar_cars
    save_car_detail(used_cars)
  end
  
  task :all_used_cars => [:load_carwale_cars, :load_click_in_cars, :load_chennai_cars, :load_autonagar_cars] do    
  end
end



def scrap_carwale_cars
  require "rexml/document"
  require 'scrubyt'
  
  Scrubyt.logger = Scrubyt::Logger.new
  Hpricot.buffer_size = 204800
  
  used_cars = Scrubyt:: Extractor.define do
    #url for the scarpping site, here we hard coded city id as chennai.
    fetch 'http://www.carwale.com/Used/Search.aspx?city=176&dist=0&make=&model=&yearFrom=0&yearTo=0&priceFrom=0&priceTo=0&kmFrom=0&kmTo=0&st=-1'
    
    cars "//table[@id='rptListings']" do
      carlist "//tr" do            
        name "//td[2]"
        year "//td[1]"
        price "//td[3]"
        kms "//td[4]"
        color "//td[5]"
        seller_type "//td[6]"
        city "//td[7]"
        last_updated "//td[8]" 
      end
    end
    next_page 'Next'
  end
  
  #convert in to hash
  used_cars_doc = REXML::Document.new used_cars.to_xml
  puts used_cars_doc
  used_cars_array = Array.new  
  index = 1;
  no_carperpage = 40
  
  used_cars_doc.elements.each("root/cars/carlist") { |element|  
    if index != 1   
      car_detail_hash = Hash.new
      car_detail_hash['name'] = element.elements['name'].text
      year_profile_text = element.elements['year'].text    
      year_pfofile_text_array = year_profile_text.split(":",3);
      car_detail_hash['manufacture_year'] = year_pfofile_text_array[2]
      car_detail_hash['selling_price'] = element.elements['price'].text
      car_detail_hash['running_km'] = element.elements['kms'].text
      car_detail_hash['color'] = element.elements['color'].text
      car_detail_hash['seller_type'] = element.elements['seller_type'].text
      car_detail_hash['city'] = element.elements['city'].text 
      car_detail_hash['last_updated'] = element.elements['last_updated'].text
      car_detail_hash['profile_id'] = year_pfofile_text_array[0] + ":" +year_pfofile_text_array[1]
      
      index = car_detail_hash['name'].index(" ")
      make = name[0, index]
      model = name[index + 1, name.length]
      car_detail_hash['make'] = make
      car_detail_hash['model'] = model
      
      used_cars_array.push car_detail_hash
    end
  
    #reset index if the reach the end of the page
    if index == no_carperpage 
      index = 0  
    else
      index = index + 1      
    end          

  }
  
  return used_cars_array
end


def scrap_click_in_used_cars 
  require "rexml/document"
  require 'scrubyt'
  Hpricot.buffer_size = 204800
  
  Scrubyt.logger = Scrubyt::Logger.new
  
  used_cars = Scrubyt:: Extractor.define do
    #url for the scarpping site
    fetch 'http://chennai.click.in/classifieds/for-sale/1/48/used-cars.html'
    
    #parse the result 
    cars "//div[@id='classifieds']"  do
      car "//p[@class='text6']/a[@class='text14']", :generalize => true  do 
        car_details do
           details '/html/body/table/tr/td/table/tr[3]/td/table/tr' do
              detail '//td' do
                  name '//span[3]'
                  value '//span[4]'
              end 
              detail '//td' do
                  name '//span[5]'
                  value '//span[6]'
              end
              detail '//td' do
                  name '//span[7]'
                  value '//span[8]'
               end
              detail '//td' do
                  name '//span[9]'
                  value '//span[10]'
              end  
              detail '//td' do
                  name '//span[11]'
                  value '//span[12]'
                end  
                detail '//td' do
                  name '//span[13]'
                  value '//span[14]'
              end
               detail '//td' do
                  name '//span[15]'
                  value '//span[16]'
               end   
               detail '//td' do
                  name '//span[17]'
                  value '//span[18]'
                end 
                alldetails '//td'  do
                  name "//span[@class='text5']"
                  value "//span[@class='subtitle']"
                end 
             end           
           end
           car_link 'href', :type => :attribute
      end
    end
    next_page 'Next'
  end  
  
  
  used_cars_string = used_cars.to_xml
  #puts used_cars_string
  
  #conver xml into hash
  used_cars_doc = REXML::Document.new used_cars_string
  used_cars_array = Array.new
  #puts used_cars_doc
  
  used_cars_doc.elements.each("root/cars/car") { |cars|
  
    car_detail_standard_hash = Hash.new 
    cars.elements.each("details") {|element|
      car_detail_hash = Hash.new    
      element.elements.each("detail") {|detail|
           if detail.elements['value'] != nil 
              car_detail_hash[detail.elements['name'].text] = detail.elements['value'].text
           else 
             car_detail_hash[detail.elements['name'].text] = ''
           end
      }
      
      car_detail_standard_hash['manufacture_year'] = car_detail_hash['Year:']
      car_detail_standard_hash['selling_price'] = car_detail_hash['Price:']
      car_detail_standard_hash['running_km'] = car_detail_hash['Kms Done:']        
      car_detail_standard_hash['make'] = car_detail_hash['Make:']     
      car_detail_standard_hash['model'] = car_detail_hash['Model:']
      car_detail_standard_hash['color'] = car_detail_hash['Color:']
      
      field_name = Array.new    
      field_value= Array.new    
      
      
      #get the mobile no, the mobile no fieled not properly organized in the html page, so we need to get here
       element.elements['alldetails'].elements.each('name')  {|name|                   
                field_name.push  name.text                 
       }  
       element.elements['alldetails'].elements.each('value')  {|value|                   
                field_value.push  value.text
       }      
       #mobile field localted at last in the page         
       if field_name[field_name.length - 1]  == 'Mobile:'
         car_detail_standard_hash['mobile'] = field_value[field_value.length - 1]
       else
          car_detail_standard_hash['mobile'] = ''
       end               
    }
    carlink =cars.elements['car_link'].text
    carlink_array = carlink.split('/')   
    car_detail_standard_hash['profile_id'] = carlink_array[6]
    used_cars_array.push car_detail_standard_hash
  }
  return used_cars_array
end

def scrap_chennai_used_cars 
  require "rexml/document"
  require 'scrubyt'
  Hpricot.buffer_size = 204800
  
  Scrubyt.logger = Scrubyt::Logger.new
  
  used_cars = Scrubyt:: Extractor.define do
    #url for the scarpping site
    fetch 'http://www.carchennai.com/search.jsp'
    
    #search car by make 
    select_option 'carmake','Opel'         
    fill_textfield 'keywords', ''         
    submit
    
    #parse the result 
    cars "/html/body/table/tr/td/table/tr[8]/td/form/fieldset/table/tr/td/table[2]"  do
      car '//tr[1]/td[1]/a'  do
        car_details do
          cardetails "/html/body/form/div/table/tr/td/table/tr[6]/td/div/table/tr[2]/td/table/tr[3]/td/table/tr/td/table" do
            detail "//tr" do
              title "//td[1]"
              description "//td[2]"
            end
            image "/html/body/form/div/table/tr/td/table//tr[6]/td/div/table/tr[2]/td/table/tr[1]/td[1]/img" do
              src 'src',:type => :attribute
            end          
          end                     
        end
        car_name 'href' 
      end        
    end
    next_page 'Next Page >'
  end    
  
  used_cars_string = used_cars.to_xml
  puts used_cars_string
  
  #conver xml into hash
  used_cars_doc = REXML::Document.new used_cars_string
  used_cars_array = Array.new
  puts used_cars_doc
  
  used_cars_doc.elements.each("root/cars/car") { |element|
    car_detail_hash = Hash.new
    car_detail_hash['car_name'] = element.elements['car_name'].text    
    
    element.elements.each('cardetails') {|car_details|
      car_details.elements.each('detail') {|details|
        
        name = details.elements['title'].text
        value = ''
        
        if nil != details.elements['description']
          value =details.elements['description'].text
        end
        
        car_detail_hash[name] = value
      }
    }
    #conver hashes to application specifice names  
    car_detail_standard_hash = Hash.new
    car_detail_standard_hash['name'] = car_detail_hash['car_name']
    car_detail_standard_hash['make'] = car_detail_hash['Make:']
    car_detail_standard_hash['model'] = car_detail_hash['Make:']
    car_detail_standard_hash['seats'] = car_detail_hash['No of Seats:']
    car_detail_standard_hash['color'] = car_detail_hash['Car Colour:']    
    car_detail_standard_hash['running_km'] = car_detail_hash['Km\'s Run']
    car_detail_standard_hash['seller_type'] = car_detail_hash['Pvt/Dealer'] 
    car_detail_standard_hash['transmission'] = car_detail_hash['Transmission:']
    car_detail_standard_hash['manufacture_year'] = car_detail_hash['Car Manufactured In:']
    car_detail_standard_hash['regn_no'] = car_detail_hash['Vehicle Regn:']    
    car_detail_standard_hash['fuel_type'] = car_detail_hash['Fuel Type:']    
   
    used_cars_array.push car_detail_standard_hash
  }  
  
  return used_cars_array
end

def scrap_autonagar_cars 
  require "rexml/document"
  require 'scrubyt'
  Hpricot.buffer_size = 204800
  
  Scrubyt.logger = Scrubyt::Logger.new
  
  used_cars = Scrubyt:: Extractor.define do
    #url for the scarpping site
    fetch 'http://www.autonagar.com/search/'
    #search parameters
    select_option 'city','Chennai'
    select_option 'make','All'
    select_option 'modelid','All'
    submit
    
    cars "//div[@class='listrow3_results']" do      
      car "//div" do    
        makemodel "//span[2]"  
        year "//span[3]"
        mileage "//span[5]"
        price "//span[6]"
        color "//span[7]"
        listedon "//span[9]" 
        cardetails "//span[10]/a" do
        listed_details do    
          sellerdetails "/html/body/div/div[2]/div[2]/div[2]/div/div[2]/div/div[2]/div[@class='vehdet_leftpane']/div/div[2]/div[3]" do
              name "//div[1]/p[3]"
              mobileno "//div[2]/p[3]"
              address "//div[3]/p[3]"              
          end
        end
         detail_link  'href', :type => :attribute
        end  
      end
    end 
    #next_page "http://www.autonagar.com/search_result.html" 
  end 
  puts used_cars.to_xml
  used_cars_string = used_cars.to_xml  
  used_cars_doc = REXML::Document.new used_cars_string
  used_cars_array = Array.new

  
  used_cars_doc.elements.each("root/cars/car") { |element|    
  
   #conver hashes to application specifice names  
   car_detail_standard_hash = Hash.new
   name = element.elements['makemodel'].text
   index = name.index(" ")
   make = name[0, index]
   model = name[index + 1, name.length]
   
   car_detail_standard_hash['name'] =  name
   car_detail_standard_hash['manufacture_year'] = element.elements['year'].text
   car_detail_standard_hash['color'] = element.elements['color'].text    
   car_detail_standard_hash['running_km'] =element.elements['mileage'].text    
   car_detail_standard_hash['model'] = model
   car_detail_standard_hash['make'] = make
  
  element.elements.each('cardetails') {|car_details|
      car_details.elements.each('sellerdetails') {|details|
        car_detail_standard_hash['seller_name'] = details.elements['name'].text
        car_detail_standard_hash['seller_mobile_no'] = details.elements['mobileno'].text
        car_detail_standard_hash['seller_address'] = details.elements['address'].text
      }  
      detali_link = car_details.elements['detail_link'].text
      detailLinks = detali_link.split("-");
      profileString = detailLinks[detailLinks.length - 1]
      profileStringArray = profileString.split(".")
      car_detail_standard_hash['profile_id'] = profileStringArray[0]      
    }
    
    used_cars_array.push car_detail_standard_hash
  }  
  return used_cars_array
end


def save_car_detail(car_detail)  
  car_detail.each{|detail|
  puts detail
  
    # check whether the add already exists
    ads = Ad.find(:first, :conditions => ['profile_id = ?', detail['profile_id']])
    
    if ads==nil  
     ads = Ad.new
    end
   
    ads.title = detail['name']
    ads.car_make = detail['make']
    ads.car_model = detail['model']
    ads.car_color = detail['color']
    ads.running_km = detail['running_km']
    ads.manufacture_year = detail['manufacture_year']
    ads.regn_no = detail['regn_no']
    ads.profile_id = detail['profile_id']
    ads.price = detail['selling_price']
    ads.save
    
    print "ads => id  #{ads.id} saved successfully "
  }
end