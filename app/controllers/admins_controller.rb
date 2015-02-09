class AdminsController < ApplicationController
  before_filter :authenticate_business_owner!
  before_filter :ensure_admin
end