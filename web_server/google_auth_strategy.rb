Warden::Manager.serialize_into_session do |user|
  user.nil? ? nil : user.email
end

Warden::Manager.serialize_from_session do |email|
  User.find_or_create_by_email(email)
end

Warden::Strategies.add(:google) do
  def authenticate!
    email_address = env['rack.auth']['user_info']['email']

    if email_address.include? "factorylabs.com"
      success! email_address
    else
      fail! "The email address: #{email_address} ain't gonna cut it."
    end
  end
end
