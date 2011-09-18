class User < ActiveRecord::Base
  has_many :messages

  validates :email, presence: true

  def display_name
    nick || email
  end

  def as_json(options = {})
    super(
      only: [ :id, :first_name, :last_name, :email ],
      methods: [ :display_name ]
    )
  end
end
