require 'tilt'

module ViewHelpers
  def render_view(view_name, variables = {})
    Tilt.new(find_template(view_name)).render(nil, variables)
  end

protected

  def find_template(view_name)
    base = "views/#{view_name}.html"
    [ "haml", "erb" ].each do |extension|
      path = "#{base}.#{extension}"
      return path if File.exist?(path)
    end
  end

  def public_asset_path(path)
    "/bots/#{bot_lowercase_name}/public#{path}"
  end
end
