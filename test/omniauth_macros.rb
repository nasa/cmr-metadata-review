module OmniauthMacros
  def mock_auth_hash
    omniauth_hash = {'provider' => 'urs',
                     'uid' => '12345',
                     'info' => {
                       'first_name' => 'chris',
                       'last_name' => 'gokey',
                       'email_address' => 'cgokey@sgt-inc.com',
                     },
                     'extra' => {'raw_info' =>
                                   {'user_type' => 'my_user_type',
                                    'organization' => 'NASA'
                                   }
                     }
    }
    OmniAuth.config.add_mock(:urs, omniauth_hash)
  end
end