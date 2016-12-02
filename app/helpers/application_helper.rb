module ApplicationHelper
  def path_to_assets(part)
    assets_container = @assets_container || $assets_container
    content_tag(:script, "", { src: "#{assets_container[part]['js']}" })
  end
end
