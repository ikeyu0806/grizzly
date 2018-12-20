class Post < ApplicationRecord
  MAX_DISPLAY = 10

  belongs_to :user
  validates :title, presence: true
  validates :content, presence: true

  has_many :likes, dependent:   :destroy

  scope :recent_posts,
        -> { order(created_at: :desc).limit(MAX_DISPLAY) }
end
