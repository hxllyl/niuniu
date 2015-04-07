class Banner < ActiveRecord::Base

  paginates_per 20

  mount_uploader :image, BannerUploader


  POI_OPTIONS = [
      ['左', 'left'],
      ['右', 'right'],
      ['上', 'up'],
      ['下', 'down']
  ]

  validates_presence_of :image, message: 'image must be existed'

  scope :valid, -> { all }
  # scope :live, -> {where("banners.begin_at <= ? and banners.end_at < ?", Time.now, Time.now)}

  def to_hash
    {
      id: id,
      title: title,
      poi: poi,
      position: position,
      url: image.try(:url),
      redirect_way: redirect_way
    }
  end

end
