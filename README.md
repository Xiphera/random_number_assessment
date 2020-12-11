# ![alt text](https://xiphera.com/img/logo_grey_new.png "Xiphera") Random number assessment

## Overview

This is the general guidelines and instructions to run common test suites to random data binary files. This repository does not include any of the test suite softwares, only a script, C application for _TestU01_ and instructions how to run these softwares. These test suites are provided by a 3rd party and credit goes to them.

![alt text](https://xiphera.com/img/xiphera_logo_embedded_12pt.png "Xiphera") uses and recommends using only _practrand_, _gjrand_ and _TestU01_ to assess the quality of the random numbers. There have been several cases where only these three have shown signs of statistical anomalies and several cases where several others have also indicated the same result as these test suites. Literature also praises these two test suites above others.

These test suites require a lot of data to guarantee the statistical quality of the random numbers. ![alt text](https://xiphera.com/img/xiphera_logo_embedded_12pt.png "Xiphera") has piped multiple tebibytes (TiB) of TRNG data to each of these test suites. However, practical and still effective amount of data is between two and four gibibytes (GiB).

There are several other widely used assessment suites like NIST STS (SP800-22), NIST SP800-90B, Dieharder, FIPS, AIS-31 and others. These can be used to verify that TRNG complies with standards but are not encouraged otherwise.

Installation guides are provided here that are encouraged, however there is also `install.sh` which does the job, but does not have any guarantee that it will work. All installation are done from this folder and it presumed that there is random file located at `../random/xip8001b.bin`. This is the default location where the  [![alt text](https://xiphera.com/img/xiphera_logo_embedded_12pt.png "Xiphera")'s TRNG AWS](https://www.xilinx.com/products/acceleration-solutions/true-random-number-generator.html "Xiphera AWS implementation guide website") evaluation platform extracts the random binary data file.

### PractRand

One of the most thorough statistical test suites, is PractRand (Practically Random), a C++ library of also providing statistical tests for any types of RNGs.

PractRand is mainly used with a PRNG, because the integrated and independent PRNGs can be directly connected to the test suite without storing all the required data into a file. This is possible also with the ![alt text](https://xiphera.com/img/xiphera_logo_embedded_12pt.png "Xiphera")s TRNG. However, PractRand supports file analysis also.

Download and extract the latest version of the software from [SourceForge](https://sourceforge.net/projects/pracrand/files/ "sourceforge.net/projects/pracrand/files/"). Or use the commands below.

##### Installation

```bash
mkdir practrand
cd ./practrand
wget https://sourceforge.net/projects/pracrand/files/PractRand-pre0.95.zip
unzip PractRand-pre0.95.zip
g++ -c src/*.cpp src/RNGs/*.cpp src/RNGs/other/*.cpp -O3 -Iinclude -pthread -std=c++11
ar rcs libPractRand.a *.o
g++ -o RNG_test tools/RNG_test.cpp libPractRand.a -O3 -Iinclude -pthread -std=c++11
rm *.o
```

##### Executing independently

Can be run independently with binary file input as per example:
```bash
cd practrand
cat ../random/xip8001b.bin | ./RNG_test stdin -multithreaded -tlmin 256KB -tlmax 2GB -te 1 -tf 2 -tlshow 1GB
```
Options ( `./RNG_test -h` for more info):
```bash
  -tf 2 #FOLDING  may be 0, 1, or 2.
  -te 1 #EXPANDED may be 0 or 1.
  -multithreaded  #Self-explanatory
  -tlmin 256KB # Minimum test length, aka. where to start.
  -tlmax 2000004KB # Maximum test length (2000004KB works for 2000MB file)
  -tlshow 1GB # When to show interim results.
```

### gjrand
This is the other high quality and easy to use RNG test suite.

This is the gjrand test suite for PRNGs. "As good as PractRand, perhaps even a hair better."  ([Said](http://pracrand.sourceforge.net/Tests_overview.txt "The original source of the statement") the developer of PractRand)

##### Installation

Download the latest version of the test suite from [SourceForge](https://sourceforge.net/projects/gjrand/ "sourceforge.net gjrand"). Or use the commands below.

```bash
wget https://downloads.sourceforge.net/project/gjrand/gjrand/gjrand.4.3.0/gjrand.4.3.0.tar.bz2
tar -xjvf gjrand.4.3.0.tar.bz2
cd ./gjrand.4.3.0.0/src
./compile
cd ../testunif/src
./compile
```

##### Executing independently

Can be ran independently. Use `mcp --help` to see all the options. Number behind the command means the amount of bytes tested. Need to be in correct folder to run.

``` bash
cd ./gjrand.4.3.0.0/testunif/
./mcp 2000M < ../../random/xip8001b.bin #2000M is the size to be tested
```


### TestU01

TestU01 is very comprehensive statistical test suite and the batteries require a lot of data. Crush and Big Crush batteries do not accept binary file assessment, so those are not included. However, ![alt text](https://xiphera.com/img/xiphera_logo_embedded_12pt.png "Xiphera") has piped data directly to the _TestU01_  Crush and Big Crush batteries and the ![alt text](https://xiphera.com/img/xiphera_logo_embedded_12pt.png "Xiphera") TRNG passes both tests. The _TestU01_ - ![alt text](https://xiphera.com/img/xiphera_logo_embedded_12pt.png "Xiphera") edition implements the following batteries found in the _TestU01_ library:

 - Rabbit
 - Small Crush
 - Pseudo FIPS 140-2
 - Alphabit
 - Block Alphabit

For xiphera-testu01.c to work, _TestU01_ library needs to be installed. You can download the library [here](http://simul.iro.umontreal.ca/testu01/TestU01.zip "http://simul.iro.umontreal.ca/testu01/TestU01.zip") or use the `wget` command below.

[Source](http://simul.iro.umontreal.ca/testu01/tu01.html "simul.iro.umontreal.ca/testu01/tu01.html")

##### Installation
The C library needs to be made and installed with following example:
```bash
wget http://simul.iro.umontreal.ca/testu01/TestU01.zip
cd ./TestU01-1.2.3
sudo ./configure # Optionally configure installation location `--prefix=/tools/testu01`
sudo make
sudo make install
# Additionally, copy these to ~/.bashrc also.
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
export LIBRARY_PATH=/usr/local/lib:${LIBRARY_PATH}
export C_INCLUDE_PATH=/usr/local/lib:${C_INCLUDE_PATH}
```

##### xiphera-testu01.c

This c program runs all the batteries with correct parameters. To compile the `xiphera-testu01.c`, run the following:

```bash
gcc xiphera_testu01.c -o xiphera_testu01 -ltestu01 -lprobdist -lmylib -lm
```

##### Executing independently

Can be ran independently. Provide the tested file name. The argument `-v` controls the verbosity of the _TestU01_ tests.
``` bash
./xiphera_testu01 ../random/xip8001b.bin -v
```

### `ent`

The `run_tests.sh` script calculates statistical entropy values with a tool called `ent`. The following values can instantly provide crucial evidence about statistical errors in the random data. The tool provides the Shannon entropy estimation, which is not calculated by other test suites.

[Source netsite](https://www.fourmilab.ch/random/ "fourmilab.ch ent tool homepage")


Ent calculates the following statistical attributes:
 - Shannon entropy
 - reduced size of optimal compression
 - chi square distribution
 - arithmetic mean
 - Monte Carlo value for Pi
 - serial correlation coefficient

##### Installation

```bash
mkdir ent
cd ent
wget http://www.fourmilab.ch/random/random.zip
unzip random.zip
make
```

##### Executing independently

```bash
./ent ../../random/xip8001b.bin # Optionally with bit argument "-b"
```


### run_tests.sh

All of the tests above can be executed sequentially using this script. The script also collects the results into single text file located in the results directory.

Example, which runs tests for a single file even if there were results already present:
```bash
sudo chmod a+x ./run_tests.sh # makes the script executable
./run_tests.sh -h #Open help.
./run_tests.sh -f ../random/xip8001b.bin -r
```
The argument `-f` denotes that a single file is to be tested followed by the location of the file.

The argument `-r` denotes rerun tests even if there is results already for that file. Useful in batch mode.

The argument `-d` is passed with the folder to be tested, this allows the script to be ran in batch mode, which enables the testing for a whole folder.  All `*.bin` files inside the directory are tested.

The argument `-l` denotes the legacy mode. In this mode also Dieharder, NIST SP800-22 and SP800-90B test suites are executed. However, this is not necessary and the test suites need to be installed.

##### Legacy dependencies

Can be acquired from the links below. Are needed if `-l` is used on the script

  - [dieharder by Robert G. Brown](https://webhome.phy.duke.edu/~rgb/General/dieharder.php "dieharder by Robert G. Brown Duke University Physics Department")
  - [NIST SP800-90B Entropy Assessment](https://github.com/usnistgov/SP800-90B_EntropyAssessment "NIST SP800-90B Entropy Assessment")
  - [NIST SP800-22 STS python by David Johnston](https://github.com/dj-on-github/sp800_22_tests "David Johnston python implementation on GitHub")




## Reading the results

If all went well results file should be now available in the `results`-folder. The three test suites clearly state and summarise if there were any errors. Some failures and unusual values suppose to be present, these are random numbers after all, and should randomly fail to be perfectly random. However, if multiple test suites point out same unusual statistical properties there should be something to worry about. Tests can be then applied to other files produced by the same instance to make sure that these failures were just random occurrences.
