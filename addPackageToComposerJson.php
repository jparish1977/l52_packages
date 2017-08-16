<?php
$composerJsonPath=$argv[1]."/composer.json";
$composerConfig=json_decode(file_get_contents($composerJsonPath), true);


$vendor=ucfirst(strtolower($argv[2]));
$package=ucfirst(strtolower($argv[3]));

$composerConfig["autoload"]["psr-4"][$vendor."\\".$package."\\"] = "packages/".strtolower($vendor)."/".strtolower($package)."/src";

file_put_contents($composerJsonPath, json_encode($composerConfig, JSON_PRETTY_PRINT));
