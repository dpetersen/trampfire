Warden::Manager.serialize_into_session do |user|
  user.nil? ? nil : user.email
end

Warden::Manager.serialize_from_session do |email|
  User.find_by_email(email)
end

Warden::Strategies.add(:google) do
  def authenticate!
    email = env['rack.auth']['user_info']['email']

    if email.include? "factorylabs.com"
      success! User.find_or_create_by_email(email)
    else
      fail! "The email address: #{email} ain't gonna cut it."
    end
  end
end
