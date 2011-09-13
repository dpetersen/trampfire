class User < ActiveRecord::Base
  has_many :messages

  validates :email, presence: true

  def display_name
    nick || email
  end

  def to_hash
    {
      id: id,
      first_name: first_name,
      last_name: last_name,
      email: email,
      display_name: display_name
    }
  end
end
