Install laravel in the l52_packages folder
```
cd /vagrant/l52_packages
php /vagrant/composer.phar create-project --prefer-dist laravel/laravel ./ "5.2.*"
```

Create a package skeleton
```
/vagrant/create_package.sh /vagrant/l52_packages japtest simplepackage
```
