#!/usr/bin/env bash

# @Author: Valtteri Marttila <vakkeli>
# @Date:   Friday, December 11th 2020, 13:50:46
# @Email:  valtteri.marttila@xiphera.com
# @Filename: install.sh
# @Last modified by:   vakkeli
# @Last modified time: Friday, December 11th 2020, 13:53:50
# @Copyright: Xiphera Ltd.

cd ~/

mkdir practrand
cd ./practrand
wget https://sourceforge.net/projects/pracrand/files/PractRand-pre0.95.zip
unzip PractRand-pre0.95.zip
g++ -c src/*.cpp src/RNGs/*.cpp src/RNGs/other/*.cpp -O3 -Iinclude -pthread -std=c++14
ar rcs libPractRand.a *.o
g++ -o RNG_test tools/RNG_test.cpp libPractRand.a -O3 -Iinclude -pthread -std=c++14
rm *.o

cd ..

wget https://downloads.sourceforge.net/project/gjrand/gjrand/gjrand.4.3.0/gjrand.4.3.0.tar.bz2
tar -xjvf gjrand.4.3.0.tar.bz2
cd ./gjrand.4.3.0.0/src
./compile
cd ../testunif/src
./compile

cd ../../../

wget http://simul.iro.umontreal.ca/testu01/TestU01.zip
unzip TestU01.zip
cd ./TestU01-1.2.3
sudo ./configure # Optionally configure installation location `--prefix=/tools/testu01`
sudo make
sudo make install
# Additionally, copy these to ~/.bashrc also.
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
export LIBRARY_PATH=/usr/local/lib:${LIBRARY_PATH}
export C_INCLUDE_PATH=/usr/local/lib:${C_INCLUDE_PATH}

cd ..

gcc xiphera_testu01.c -o xiphera_testu01 -ltestu01 -lprobdist -lmylib -lm

mkdir ent
cd ent
wget http://www.fourmilab.ch/random/random.zip
unzip random.zip
make

cd ..

sudo chmod a+x ./run_tests.sh
./run_tests.sh -h
