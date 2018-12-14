sh /scripts/create_db.sh postgres cmrdash
sh /scripts/create_db.sh postgres cmrdash_test
sh /scripts/create_user.sh postgres cmrdash dashpass cmrdash
sh /scripts/create_user.sh postgres cmrdash_test dashpass cmrdash_test

