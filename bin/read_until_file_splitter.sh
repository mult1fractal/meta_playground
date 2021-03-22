#!/bin/env bash

while getopts "a:" arg; do
      case "${arg}" in
        
        a)
            read_until_file=${OPTARG}
            ;;
    
    esac
done

cat ${read_until_file} | cut -d "," -f6,7,8 | head > test.csv