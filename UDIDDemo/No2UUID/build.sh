#!/bin/sh

#  build.sh
#  No2UUID
#
#  Created by zhaojun on 16/7/26.
#  Copyright © 2016年 zhaojun. All rights reserved.
curentDir=`pwd`

projectDir=$curentDir
headerDir=$curentDir/sdk/No2UUID/Include
libDir=$curentDir/sdk/No2UUID/lib

rm -rf $curentDir/sdk
rm -rf $curentDir/sdk/No2UUID
rm -rf $headerDir
rm -rf $libDir

mkdir $curentDir/sdk
mkdir $curentDir/sdk/No2UUID
mkdir $headerDir
mkdir $libDir

xcodebuild -project No2UUID.xcodeproj -alltargets -sdk iphoneos -configuration Release
xcodebuild -project No2UUID.xcodeproj -alltargets -sdk iphonesimulator -configuration Release

mv build/Release-iphoneos/libNo2UUID.a $libDir/libNo2UUIDOS.a
mv build/Release-iphonesimulator/libNo2UUID.a $libDir/libNo2UUIDSimulator.a

cd $libDir

lipo libNo2UUIDOS.a libNo2UUIDSimulator.a -create -output libNo2UUID.a
lipo -info libNo2UUID.a


rm libNo2UUIDSimulator.a
rm libNo2UUIDOS.a

rm -rf $projectDir/build

cp $projectDir/No2UUID/*.h $headerDir/

echo "finished build ios library !"