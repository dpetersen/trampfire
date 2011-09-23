class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag

  validates :original_message, :tag, presence: true

  def self.create_for_user_from_json_string(user, json_string)
    hash = JSON.parse(json_string)
    create(
      user: user,
      tag: Tag.find_by_name!(hash["tag"]),
      original_message: hash["data"].strip
    )
  end

  def author
    if bot.present? then bot
    elsif user.present? then user.display_name
    else "System"
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

  # Associate with a Tag by name.  Intended to be called through the
  # MessageFactoryHandler by bots who know names but not ids.
  #
  # tag_name - Name of a tag in the database.
  #
  # Returns nothing.
  def tag_name=(tag_name)
    self.tag = Tag.find_by_name!(tag_name)
  end

  # Can't use 'include' here because it won't call as_json on children
  # See: https://github.com/rails/rails/issues/576
  def as_json(options = {})
    super(
      only: [ :id, :original_message, :created_at, :bot ],
      methods: [ :author, :data, :user_hack, :tag_hack ]
    )
  end
end
