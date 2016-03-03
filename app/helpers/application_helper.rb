module ApplicationHelper

	def t(translate)
		I18n.t(translate)
	end

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = 'The School Business App'
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def gravatar_for(user, size=80)
  	gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
  	gravatar_url = "http://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size.to_s}"
  	image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
