module ViewHelpers
  def render_view(view, variables = {})
    template = File.open("views/#{view}.html.erb", variables).read
    Erubis::Eruby.new(template).result(variables)
  end

protected

  def public_asset_path(path)
    "/bots/#{bot_lowercase_name}/public#{path}"
  end
end
