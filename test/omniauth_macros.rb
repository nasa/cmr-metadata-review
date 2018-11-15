module OmniauthMacros
  def mock_auth_hash
    omniauth_hash = {'provider' => 'urs',
                     'uid' => '12345',
                     'info' => {
                       'first_name' => 'john',
                       'last_name' => 'smith',
                       'email_address' => 'jsmith@someplace.com',
                     },
                     'extra' => {'raw_info' =>
                                   {'user_type' => 'my_user_type',
                                    'organization' => 'my organization'
                                   }
                     },
                     'credentials' => {'access_token': '12345'}
    }
    OmniAuth.config.add_mock(:urs, omniauth_hash)
  end
end