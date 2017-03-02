# encoding: utf-8
require File.join(File.dirname(__FILE__), "../spec_helper.rb")

describe "Her::Model and ActiveModel::Validations" do
  context "validating attributes" do
    before do
      spawn_model "Foo::User" do
        attributes :fullname, :email, :age
        validates_presence_of :fullname
        validates_presence_of :email
        validates_numericality_of :age
      end
    end

    it "validates attributes when calling #valid?" do
      user = Foo::User.new
      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("Fullname can't be blank")
      expect(user.errors.full_messages).to include("Email can't be blank")
      user.fullname = "Tobias Fünke"
      user.email = "tobias@bluthcompany.com"
      user.age = 35
      expect(user).to be_valid
    end
  end

  context "handling server errors" do
    before do
      spawn_model("Foo::Model") do
        def errors
          @response_errors
        end
      end

      class User < Foo::Model; end
      @spawned_models << :User
    end

    it "validates attributes when calling #valid?" do
      user = User.new(_errors: ["Email cannot be blank"])
      expect(user.errors).to include("Email cannot be blank")
    end
  end
end
