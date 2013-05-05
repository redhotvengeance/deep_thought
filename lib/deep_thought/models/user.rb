require 'bcrypt'

module DeepThought
  class User < ActiveRecord::Base
    attr_accessor :password, :password_confirmation

    before_save :generate_password_digest

    validates_presence_of :email
    validates_uniqueness_of :email
    validates_format_of :email, :with => /.+@.+\..+/, :allow_blank => false, :message => "email address not valid"
    validates_presence_of :password, :on => :create
    validates_presence_of :password_confirmation, :on => :create
    validates_confirmation_of :password

    def self.authenticate(email, unencrypted_password)
      user = find_by_email(email)

      if user && BCrypt::Password.new(user.password_digest) == unencrypted_password
        user
      else
        nil
      end
    end

    private

    def generate_password_digest
      self.password_digest = BCrypt::Password.create(self.password, :cost => 12)
    end
  end
end
