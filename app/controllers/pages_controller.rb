class PagesController < ApplicationController
  
  before_filter :authenticate_user!, only: [:dashboard]
  
  
end