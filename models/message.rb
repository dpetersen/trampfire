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

  def type
    if user.present? then "chat"
    else "system"
    end
  end

  def data
    self.final_message || self.original_message
  end

  # Getting around an #as_json issue.
  def user_hack
    user.as_json
  end

  # See #author
  def tag_hack
    tag.as_json
  end

  # Can't use 'include' here because it won't call as_json on children
  # See: https://github.com/rails/rails/issues/576
  def as_json(options = {})
    super(
      only: [ :id, :original_message, :created_at ],
      methods: [ :type, :data, :user_hack, :tag_hack ]
    )
  end
end
