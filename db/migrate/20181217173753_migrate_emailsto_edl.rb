class MigrateEmailstoEdl < ActiveRecord::Migration
    def up
        execute "UPDATE users SET email='kbugbee@itsc.uah.edu' WHERE email='kaylin.m.bugbee@nasa.gov' ;"
        execute "UPDATE users SET email='ingridgsolera@gmail.com' WHERE email='is0028@uah.edu';"
        execute "UPDATE users SET email='carlee.f.loeser@nasa.gov' WHERE email='carlee.loeser@nasa.gov';"
        execute "UPDATE users SET email='jr0020@temp' WHERE email='jr0020@uah.edu'";
        execute "UPDATE users SET email='jr0020@uah.edu' WHERE email='jeanne.leroux@nsstc.uah.edu';"
	      execute "UPDATE users SET email='jeanne.leroux@nsstc.uah.edu' WHERE email='jr0020@temp';"
    end

    def down
        execute "UPDATE users SET email='kaylin.m.bugbee@nasa.gov' WHERE email='kbugbee@itsc.uah.edu'";
        execute "UPDATE users SET email='is0028@uah.edu' WHERE email='ingridgsolera@gmail.com'";
        execute "UPDATE users SET email='carlee.loeser@nasa.gov' WHERE email='carlee.f.loeser@nasa.gov'";
        execute "UPDATE users SET email='jr0020@temp' WHERE email='jeanne.leroux@nsstc.uah.edu'";
        execute "UPDATE users SET email='jeanne.leroux@nsstc.uah.edu' WHERE email = 'jr0020@uah.edu'";
        execute "UPDATE users SET email='jr0020@uah.edu' WHERE email = 'jr0020@temp'";
    end
end
