class Helper < ActiveRecord::Base
  validates :title, :content, presence: true

  def to_hash
    {
     title: title,
     content: content,
     id: id,
     url: "/helpers/#{id}"
    }
  end
end
