class Category < ActiveRecord::Base
  has_many :ads
  belongs_to :parent_category
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :within => 4..40
  validates_presence_of :slug
  validates_uniqueness_of :slug, :case_sensitive => false
  validates_length_of :slug, :within => 3..40
  
  
  
  # set default categories
  def self.set_defaults
    if self.find(:all).blank?
      # set default parents
      ParentCategory.set_defaults
      
      # parent: "for sale"
      c = self.create(:name => 'Santro Xing', :slug => 'Hyundai Santro Xing', :parent_category_id => 1)
      c = self.create(:name => 'Getz Prime', :slug => 'Getz Prime', :parent_category_id => 1)
      c = self.create(:name => 'Accent', :slug => 'Accent', :parent_category_id => 1)
      
      # parent: "jobs"
      c = self.create(:name => "Alto", :slug => 'Alto', :parent_category_id => 2)
      c = self.create(:name => 'Zen Estilo', :slug => 'Zen Estilo', :parent_category_id => 2)
      c = self.create(:name => 'Swift', :slug => 'Swift', :parent_category_id => 2)
      
      # parent: "services"
      c = self.create(:name =>  'City ZX', :slug => 'City ZX', :parent_category_id => 3)
      c = self.create(:name => 'Accord 2008', :slug => 'Accord 2008', :parent_category_id => 3)
      c = self.create(:name => 'Civic Hybrid', :slug => 'Civic Hybrid', :parent_category_id => 3)
      
      # parent: "gigs"
      c = self.create(:name => 'Ikon', :slug => 'Ikon', :parent_category_id => 4)
      c = self.create(:name => 'Fusion', :slug => 'Fusion', :parent_category_id => 4)
      c = self.create(:name => 'Fiesta', :slug => 'Fiesta', :parent_category_id => 4)
    end
  end
  
  def self.display_paged_data(page)
    paginate(:page => page, :per_page => 10,:order => "name")
  end

end

