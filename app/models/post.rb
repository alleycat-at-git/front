class Post < ActiveRecord::Base

  def self.ai_picked
    self.order(likes_count: :desc).limit(10)
  end
  
  def attachment_vk_url
    attachment_type == "video" ? "http://vk.com/wall#{owner_id}_#{vk_id}"\
            "?z=#{attachment_type}#{attachment_owner_id}_#{attachment_id}" :
            "http://vk.com/#{attachment_type}#{attachment_owner_id}_#{attachment_id}"
  end

  def vk_url
    "http://vk.com/wall#{owner_id}_#{vk_id}"
  end

end
