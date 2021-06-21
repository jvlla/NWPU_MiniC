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
elif [ $1 = "help" ]
then
    echo "本shell脚本用于进行批量测试（虽然只有基础和错误测试可以过……）"
    echo "参数为basic, additional, error, optional, help"
    echo "分别以miniC_test_cases中相应文件夹作为compiler_haotian程序的参数相应的批量进行基础、附加、错误、可选测试"
else
    echo "参数错误，请输入basic, additional, error, optional或help"
    echo "输入help参数获得帮助"
fi
