require 'spec_helper'

describe InquiriesController do
  after do
    ActionMailer::Base.deliveries.clear
  end

  describe "GET new" do
    it "renders the index template" do
      get :new
      expect(response).to render_template :new
    end
 
    it "sets the new @inquiry" do
      get :new
      expect(assigns(:inquiry)).to be_instance_of(Inquiry)
    end
  end

  describe "POST create" do
    context "with valid input" do
      before do
        post :create, inquiry: {name: "Joe", email: "jow@example.com", phone_number: "5556667788", message: "This is a message."}
      end

      it "redirects to the index page" do
        expect(response).to redirect_to new_inquiry_path
      end

      it "sends from the right email address" do
        message = ActionMailer::Base.deliveries.last
        expect(message.from).to eq(['jow@example.com'])
      end

      it "sets the flash success message" do
        expect(flash[:success]).to be_present
      end
    end

    context "with invalid input" do
      before do
        post :create, inquiry: {name: "Joe", email: "joe@", phone_number: "5556667788", message: "This is a message."}
      end

      it "renders the index template" do
        expect(response).to render_template :new
      end
      
      it "sets the @inquiry" do
        expect(assigns(:inquiry).email).to eq("joe@") 
      end

      it "sets the flash error message" do
        expect(flash[:error]).to be_present
      end 
    end
  end
end


