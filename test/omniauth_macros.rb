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

  # This stubs access to URS for retrieving user_info and tokens
  def stub_urs_access
    Cmr.stubs(:get_user_info).with{ |*args| args[0]}.returns [200, nil]
    Cmr.stubs(:refresh_access_token).with{|*args| args[0]}.returns ['access_token', 'refresh_token']
  end

end