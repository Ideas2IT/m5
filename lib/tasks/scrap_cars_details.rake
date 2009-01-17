require 'rubygems'
require 'active_record'
require 'active_record/fixtures'



DATA_DIRECTORY = File.join(RAILS_ROOT, "lib", "tasks", "scrap")

namespace :scrap do 
  desc "Scraping used cars details from the chennai car site"  
  task :load_chennai_cars => :environment do
    used_cars = scrap_chennai_used_cars        
    save_car_detail(used_cars)   
  end
  
  desc "Scraping used cars details from the car wale site "   
  task :load_carwale_cars => :environment do
    used_cars = scrap_carwale_cars
    save_car_detail(used_cars)
  end
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
          cardetails "/html/body/form/div/table/tr/td/table//tr[6]/td/div/table/tr[2]/td/table/tr[3]/td/table/tr/td/table" do
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

def scrap_carwale_cars
  require "rexml/document"
  require 'scrubyt'
  
  Scrubyt.logger = Scrubyt::Logger.new
  Hpricot.buffer_size = 204800
  
  used_cars = Scrubyt:: Extractor.define do
    #url for the scarpping site, here we hard coded city id as chennai.
    fetch 'http://www.carwale.com/Used/Search.aspx?city=176&dist=0&make=&model=&yearFrom=0&yearTo=0&priceFrom=0&priceTo=0&kmFrom=0&kmTo=0&st=-1'
    #click_link 'Buy Car'
    #search car by make 
    #select_option 'drpCity','Chennai'
    #select_option 'drpCityDist','this city'
    #6submit    
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
        profileid "//td[1]/span"
      end
    end
    next_page 'Next'
  end
  
  #convert in to hash
  used_cars_doc = REXML::Document.new used_cars.to_xml
  used_cars_array = Array.new  
  
  used_cars_doc.elements.each("root/cars/carlist") { |element|
    car_detail_hash = Hash.new
    car_detail_hash['name'] = element.elements['name'].text    
    car_detail_hash['car_manufacture_year'] = element.elements['year'].text
    car_detail_hash['selling_price'] = element.elements['price'].text
    car_detail_hash['running_km'] = element.elements['kms'].text
    car_detail_hash['color'] = element.elements['color'].text
    car_detail_hash['seller_type'] = element.elements['seller_type'].text
    car_detail_hash['city'] = element.elements['city'].text 
    car_detail_hash['last_updated'] = element.elements['last_updated'].text     
    used_cars_array.push car_detail_hash
  }
  
  pp used_cars_array
  
  return used_cars_array
end

def save_car_detail(car_detail)    
  #creating ads Todo: standatize names as per the applicaiton
  car_detail.each{|detail|
    ads = Ad.new    
    ads.title = detail['name']
    ads.car_make = detail['make']
    #ads.car_no_of_seats = detail['seats']
    ads.car_model = detail['model']
    ads.car_color = detail['color']
    ads.running_km = detail['running_km']
    #ads.seller_type = detail['seller_type']
    #ads.car_transmission = detail['transmission']
    ads.manufacture_year = detail['manufacture_year']
    ads.regn_no = detail['regn_no']    
    #ads.car_fuel_type = detail['fuel_type']        
    ads.save
    print "ads => id  #{ads.id} saved successfully "
  }
end