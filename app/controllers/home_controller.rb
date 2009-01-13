class HomeController < ApplicationController
  skip_before_filter :require_activation
  before_filter :set_up
  
  def index
    @body = "home"
    @parent_categories = ParentCategory.find :all, :order => 'name ASC'
    @cars = Car.find :all
    respond_to do |format|
      format.html
      format.atom
    end  
  end

  def set_up
    ParentCategory.set_defaults
    Category.set_defaults
  end
    
end
