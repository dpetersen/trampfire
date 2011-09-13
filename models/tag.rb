class Tag < ActiveRecord::Base
  has_many :messages

  validates :name, presence: true, uniqueness: true

  def to_hash
    {
      id: id,
      name: name
    }
  end
end
