#!/bin/bash

if [ $1 = "basic" ]
then
    for file in `find ./miniC_test_cases/Basic_function_point_check_use_cases -name "*.c"`; 
    do
        cmd="./compiler_haotian $file"
        echo $cmd
        echo $cmd | sh
    done
elif [ $1 = "additional" ]
then
    for file in `find ./miniC_test_cases/Additional_function_point_check_use_cases -name "*.c"`; 
    do
        cmd="./compiler_haotian $file"
        echo $cmd
        echo $cmd | sh
    done
elif [ $1 = "error" ]
then
    for file in `find ./miniC_test_cases/Error_function_point_test_cases -name "*.c"`; 
    do
        cmd="./compiler_haotian $file"
        echo $cmd
        echo $cmd | sh
    done
elif [ $1 = "optional" ]
then
    for file in `find ./miniC_test_cases/Optional_function_point_check_use_cases -name "*.c"`; 
    do
        cmd="./compiler_haotian $file"
        echo $cmd
        echo $cmd | sh
    done
else
    echo "参数为basic, additional, error, optional"
fi
