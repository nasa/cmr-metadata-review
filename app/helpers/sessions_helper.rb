module SessionsHelper

  def get_omniauth_provider_display_name(provider)
    display_name =  OmniAuth::Utils.camelize(provider)
    if provider == :urs
      display_name = "Earthdata Login"
    end
    display_name
  end

end
