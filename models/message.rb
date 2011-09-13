class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag

  validates :original_message, :tag, presence: true

  def self.create_for_user_from_json_string(user, json_string)
    hash = JSON.parse(json_string)
    create(
      user: user,
      tag: Tag.find_by_name!(hash["tag"]),
      original_message: hash["data"]
    )
  end

  def to_json
    {
      type: "chat",
      user: user.to_hash,
      tag: tag.to_hash,
      data: self.final_message || self.original_message
    }.to_json
  end
end
