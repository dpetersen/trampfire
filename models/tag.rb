class Tag < ActiveRecord::Base
  has_many :messages

  validates :name, presence: true, uniqueness: true

  def as_json(options = {})
    super(
      only: [ :id, :name ]
    )
  end
end
