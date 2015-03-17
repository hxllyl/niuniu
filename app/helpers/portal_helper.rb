# encoding: utf-8

# author: depp.yu

module PortalHelper
  
  def all_brand
    brands = Brand.all.collect{|b| [b.name, b.id] }
  end
end
