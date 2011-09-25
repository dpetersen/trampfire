class Tab < ActiveRecord::Base
  belongs_to :user
  has_many :tag_assignments, dependent: :destroy
  has_many :tags, through: :tag_assignments

  validates :name, :user, presence: true

  def self.create_from_json_for_user(user, attributes)
    a = {}
    a[:name] = attributes["name"]
    a[:tag_list] = attributes["tagList"]
    a[:user_id] = user.id

    self.create(a)
  end

protected

  def tag_list=(tag_list)
    tag_list.each do |tag_object|
      tag = Tag.find_by_id(tag_object["id"])
      self.tag_assignments.build(tab: self, tag: tag)
    end
  end
end
