module SessionsHelper

  def camelize_str (str)
    OmniAuth::Utils.camelize(str)
  end

end
