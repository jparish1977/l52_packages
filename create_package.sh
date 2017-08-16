#/bin/bash
PROJ_ROOT=$1
VENDOR=$2
PACKAGE_NAME=$3
PACKAGE_ROOT=$PROJ_ROOT/packages/$VENDOR/$PACKAGE_NAME

echo '*************************************'
echo "Clearing $PROJ_ROOT/packages/$VENDOR/$PACKAGE_NAME"
rm -r $PROJ_ROOT/packages/$VENDOR/$PACKAGE_NAME
echo '*************************************'

echo '*************************************'
echo "Creating package source folder $PACKAGE_ROOT/src"
mkdir -p $PACKAGE_ROOT/src

echo "Creating package views folder $PACKAGE_ROOT/src/views"
mkdir -p $PACKAGE_ROOT/src/views
echo '*************************************'

echo '*************************************'
echo "Initializing package"
cd $PACKAGE_ROOT
php /vagrant/composer.phar init --name "$VENDOR/$PACKAGE_NAME" 
echo '*************************************'

echo '*************************************'
echo "Adding package to $PROJ_ROOT/composer.json"
php /vagrant/addPackageToComposerJson.php "$PROJ_ROOT" "$VENDOR" "$PACKAGE_NAME"
cd $PROJ_ROOT
php /vagrant/composer.phar dump-autoload
echo '*************************************'

VENDOR_PROPER_NAME=`sed 's/\(.\)/\U\1/' <<< "$VENDOR"`
PACKAGE_PROPER_NAME=`sed 's/\(.\)/\U\1/' <<< "$PACKAGE_NAME"`

echo '*************************************'
echo "Creating ${PACKAGE_PROPER_NAME}ServiceProvider"
php artisan make:provider "${PACKAGE_PROPER_NAME}ServiceProvider"
mv app/Providers/${PACKAGE_PROPER_NAME}ServiceProvider.php $PACKAGE_ROOT/src/
PATTERN="s/namespace App\\\\Providers;/namespace ${VENDOR_PROPER_NAME}\\\\${PACKAGE_PROPER_NAME};/g"
sed -i "$PATTERN" $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}ServiceProvider.php

awk '/[/]{2}/ {if(count==0){gsub("//","//\n        include __DIR__.\"/routes.php\";")};count++} {print $0}' $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}ServiceProvider.php > $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}ServiceProvider.php.tmp
mv $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}ServiceProvider.php.tmp $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}ServiceProvider.php
echo '*************************************'

echo '*************************************'
echo "Creating ${PACKAGE_PROPER_NAME}Controller"
php artisan make:controller "${PACKAGE_PROPER_NAME}Controller"
mv app/Http/Controllers/${PACKAGE_PROPER_NAME}Controller.php $PACKAGE_ROOT/src/
PATTERN="s/namespace App\\\\Http\\\\Controllers;/namespace ${VENDOR_PROPER_NAME}\\\\${PACKAGE_PROPER_NAME};/g"
sed -i "$PATTERN" $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}Controller.php

PATTERN="s/use App\\\\Http\\\\Requests;/use App\\\\Http\\\\Requests;\\nuse App\\\\Http\\\\Controllers\\\\Controller;/g"
sed -i "$PATTERN" $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}Controller.php

PATTERN="s#//#//\\n    function sample()\{ return view('$PACKAGE_NAME::sample'); \}#g"
sed -i "$PATTERN" $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}Controller.php

awk '/[/]{2}/ {if(count == 1){gsub("//","//\n        $this->app->make(\"'$VENDOR_PROPER_NAME'\\'$PACKAGE_PROPER_NAME'\\'$PACKAGE_PROPER_NAME'Controller\");\n        $this->loadViewsFrom(__DIR__.\"/views\", \"'$PACKAGE_NAME'\");\n        $this->publishes([ __DIR__.\"/views\" => resource_path(\"views/vendor/'$VENDOR'/'$PACKAGE_NAME'\"), ]);\n")};count++} {print $0}' $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}ServiceProvider.php > $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}ServiceProvider.php.tmp
mv $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}ServiceProvider.php.tmp $PACKAGE_ROOT/src/${PACKAGE_PROPER_NAME}ServiceProvider.php
echo '*************************************'

echo '*************************************'
echo "Generating $PACKAGE_ROOT/src/routes.php"
echo "<?php" >> $PACKAGE_ROOT/src/routes.php
echo "" >> $PACKAGE_ROOT/src/routes.php
echo "  Route::get('$PACKAGE_NAME', function(){ echo 'Hello from the $PACKAGE_NAME package!'; });" >> $PACKAGE_ROOT/src/routes.php
echo "  Route::get('${PACKAGE_NAME}_sample', '${VENDOR_PROPER_NAME}\\${PACKAGE_PROPER_NAME}\\${PACKAGE_PROPER_NAME}Controller@sample');" >> $PACKAGE_ROOT/src/routes.php
echo '*************************************'


echo '*************************************'
echo "Generating $PACKAGE_ROOT/src/views/sample.blade.php"
echo "<html><body>This is the sample view!</body></html>" > $PACKAGE_ROOT/src/views/sample.blade.php

echo '*************************************'
#Devdojo\Calculator\CalculatorServiceProvider::class,
echo "Now go add ${VENDOR_PROPER_NAME}\\${PACKAGE_PROPER_NAME}\\${PACKAGE_PROPER_NAME}ServiceProvider::class to config/app.php['providers']"
echo '*************************************'