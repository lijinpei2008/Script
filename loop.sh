#!/bin/bash
echo "===================================================================== Do you need Login?(Y,y/N,n) =========================================================================="
read needLogin
if [ ${needLogin} == "Y" -o ${needLogin} == "y" ]
then
        echo "============================================================================= az login ... ================================================================================="
        az login

        echo "=============================================================== Please input you want to use account ID ... ================================================================"
        read accountId
        az account set -s ${accountId}

        echo "================================================================== Please input Container Registry Name ... ================================================================"
        read containerRegistryName
        az acr login -n ${containerRegistryName}

        echo "============================================================================== docker login ... ============================================================================"
        docker login ${containerRegistryName}.azurecr.io
fi

echo "==================================================================== Input Container Registry Name! =========================================================================="
read name
echo "=============================================================== Push Repositories(r/R)? Tags(t)? Task(T)? ===================================================================="
read tit
echo "================================================================== Do you want to loop it a few times? ======================================================================="
read num

loopCount=1
case ${tit} in
        "t")
                while ((${loopCount}<=${num}))
                do
                        docker tag hello-world ${name}.azurecr.io/newimagename:version${loopCount}
                        let "loopCount++"
                done

                echo "Push?(Y,y/N,n)"
                read _input
                if [ ${_input} == "Y" -o ${_input} == "y" ]
                then
                        docker push ${name}.azurecr.io/newimagename
                fi
        ;;

        "r"|"R")
                while ((${loopCount}<=${num}))
                do
                        docker tag hello-world ${name}.azurecr.io/newimagename${loopCount}
                        docker push ${name}.azurecr.io/newimagename${loopCount}
                        let "loopCount++"
                done
        ;;

        "T")
                while ((${loopCount}<=${num}))
                do
                        az acr task create -n Task${name}${loopCount} -r ${name} --cmd hello-world -c /dev/null
                        az acr task run -n Task${name}${loopCount} -r ${name}
                        let "loopCount++"
                done
        ;;

        *)
                echo "Error: ${tit} could not be found."
                break
        ;;

esac

echo "========================================================== Enter CTRL+C to end Or Enter other key to delete image ============================================================"
read sthmessage

#docker system prune -a #清空全部的 image 和 container 

loopCount=1
while ((${loopCount}<=${num}))
do
        docker rmi ${name}.azurecr.io/newimagename${loopCount}
        docker rmi ${name}.azurecr.io/newimagename:version${loopCount}
        let "loopCount++"
done
