class User < ActiveRecord::Base
  has_many :messages

  validates :email, presence: true

  def display_name
    nick || email
  end
end
