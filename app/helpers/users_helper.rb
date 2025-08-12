# app/helpers/users_helper.rb
require "digest/md5"

module UsersHelper
  # Returns the Gravatar for the given user.
  def gravatar_for user, options = {size: Settings.sizes.size_80}
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
