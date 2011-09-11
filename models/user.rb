class User < ActiveRecord::Base
  validates :email, presence: true

  def display_name
    nick || email
  end
end
