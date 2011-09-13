class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag

  validates :original_message, :tag, presence: true

  def self.create_for_user_from_json_string(user, json_string)
    j = JSON.parse(json_string)
    create(
      user: user,
      tag: Tag.find_by_name!(j["tag"]),
      original_message: j["data"]
    )
  end

  def to_json
    {
      type: "chat",
      user: user.display_name,
      user_id: user.id,
      tag: tag.name,
      tag_id: tag.id,
      data: self.final_message || self.original_message
    }.to_json
  end
end
