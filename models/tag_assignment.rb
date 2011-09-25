class TagAssignment < ActiveRecord::Base
  belongs_to :tab
  belongs_to :tag

  validates :tab, :tab, presence: true
end
