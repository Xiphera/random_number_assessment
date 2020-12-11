#!/usr/bin/env bash

# @Author: Valtteri Marttila <valtteri>
# @Date:   Tuesday, August 18th 2020, 9:46:35
# @Email:  valtteri.marttila@xiphera.fi
# @Filename: run_tests
# @Last modified by:   valtteri
# @Last modified time: Wednesday, December 9th 2020, 14:14:39
# @Copyright: Xiphera Ltd.

dir=''
file=''
r_flag=''
l_flag=''
v_flag=''
SECONDS=0
SECONDS2=0
SECONDS3=0

uppedfiles=$'\nThe following files were tested:'
uppedfiles+=$'\n\n'

echo $'Xiphera Ltd. random number offline testing.\n'


print_usage() {
  echo "Usage: "
  echo "      -r    Rerun tests if results files are present."
  echo "      -v    Verbose, show extra results"
  echo "      -l    Legacy mode, adds NIST tests and Dieharder"
  printf "\n"
  echo "      -d    Directory to be tested"
  echo "      OR"
  echo "      -f    File to be tested"
}

aja_testit() {
  SECONDS2=$((SECONDS))
  echo "Test results for file $1" > ./results/$1.results
  echo "Starting with ent"$'\n'

  #ENT tool
  printf "\n\n" >> ./results/$1.results
  ./ent/ent $1 |& tee -a ./results/$1.results
  printf "\n Ent results bit by bit \n" >> ./results/$1.results
  ./ent/ent -b $1 |& tee -a ./results/$1.results
  printf "\n\n" >> ./results/$1.results

  echo $'\n'$'\n'"Now running gjrand"$'\n'


  FILESIZE=$(stat -c%s $1)
  cd ./gjrand.4.3.0.0/testunif
  ./mcp $FILESIZE < ../../$1 |& tee -a ../../results/$1.results
  cd ../../

  echo $'\n'$'\n'"Running practrand"$'\n'

  if [ -n "$v_flag" ]
  then
    cat $1 | ./practrand/RNG_test stdin -a -tlmin 256KB -tlmax $((FILESIZE / 1024))K -multithreaded -te 1 -tf 2 -tlshow 1GB |& tee -a ./results/$1.results
    echo "Running TestU01 - Xiphera Edition"$'\n' |& tee -a ./results/$1.results
    ./xiphera_testu01 $1 -v |& tee -a ./results/$1.results
  else
    cat $1 | ./practrand/RNG_test stdin -tlmin 256KB -tlmax $((FILESIZE / 1024))K -multithreaded -te 1 -tf 2 -tlshow 1GB |& tee -a ./results/$1.results

    echo "Running TestU01 - Xiphera Edition"$'\n' |& tee -a ./results/$1.results
    ./xiphera_testu01 $1 |& tee -a ./results/$1.results
  fi

  if [ -n "$l_flag" ]
  then
    echo "Running Legacy tests! " |& tee -a ./results/$1.results
    echo "Continuing to dieharder"$'\n'
    dieharder -a -m 2 -k 2 -g 201 -f $1 |& tee -a ./results/$1.results
    printf "\n\n" >> ./results/$1.results
    echo "NIST SP800-22 test suite results:" &>> ./results/$1.results
    echo "Now the NIST SP800-22 test suite"$'\n'
    python3 ./sp800_22_tests-python/sp800_22_tests.py $1 |& tee -a ./results/$1.results
    echo "Finalizing with NIST SP800-90b tests: iid and non-iid"
    printf "\n\n" >> ./results/$1.results
    echo "NIST SP800-80b test suite IID results:" >> ./results/$1.results
    printf "\n" >> ./results/$1.results
    ./SP800-90B_EntropyAssessment-master/cpp/ea_iid -v $1 8 |& tee -a ./results/$1.results
    printf "\n" >> ./results/$1.results
    echo "NIST SP800-80b test suite NON-IID results:" >> ./results/$1.results
    printf "\n" >> ./results/$1.results
    ./SP800-90B_EntropyAssessment-master/cpp/ea_non_iid -v $1 8 |& tee -a ./results/$1.results
  else
    echo "Skipping Legacy test suites: (add -l to run these)"$'\n' |& tee -a ./results/$1.results
    echo "dieharder"$'\n' |& tee -a ./results/$1.results
    echo "NIST SP800-22 test suite"$'\n' |& tee -a ./results/$1.results
    echo "NIST SP800-90b"$'\n'$'\n' |& tee -a ./results/$1.results
  fi
  echo "All done!"
  SECONDS3=$((SECONDS-SECONDS2))
  echo "Time elapsed:" $SECONDS3 "seconds"$'\n'
  uppedfiles+="$1"
  uppedfiles+=$'\n'
}


while getopts 'lvhrd:f:' flag; do
  case "${flag}" in
    r) r_flag='true' ;;
    l) l_flag='true' ;;
    v) v_flag='true' ;;
    d) dir="${OPTARG}" ;;
    f) file="${OPTARG}" ;;
    h) print_usage ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [ -e "$file" ]
then
  if [ -e ./results/"$file".results ]
  then
    echo "File:" "$file" "already has results"
    if [ -n "$r_flag" ]
    then
      echo "Rerunning tests for file:" "$file" "which already had results"
      aja_testit "$file"
    else
      echo "To rerun tests, apply -r argument"
    fi
  else
    echo "Running tests for file:" "$file" "which did not have results before"
    aja_testit "$file"
  fi
else
  if [ -d "$dir" ]
  then
    for fiilu in "$dir"/*.bin
    do
      if [ -e "$dir"/results/"$fiilu".results ]
      then
        echo "File:" "$dir"/"$fiilu" "already has results"
        if [ -n "$r_flag" ]
        then
          echo "Rerunning tests for file:" "$dir"/"$fiilu" "which already had results"
          aja_testit "$fiilu"
        else
          echo "To rerun tests, apply -r argument"
        fi
      else
        echo "Running tests for file:" "$dir"/"$fiilu" "which did not have results before"
        aja_testit "$fiilu"
      fi
    done
  else
    echo "invalid arguments, use -h to help"
  fi
fi
echo "$uppedfiles"
echo "The time elapsed for these tests were" $SECONDS "seconds."
