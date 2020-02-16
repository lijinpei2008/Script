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
echo "======================================================== Push Repositories(r/R)? Tags(t)? Task(T)? ScopeMap(s/S) ============================================================="
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

        "s"|"S")
                while ((${loopCount}<=${num}))
                do
                        az acr scope-map create -n ${name}scopemap${loopCount} --repository hello-world${loopCount} content/read content/write -r ${name} --description "Sample scope map."
                        
                        az acr token create -n ${name}token${loopCount} --scope-map ${name}scopemap${loopCount} -r ${name}
                        
                        az acr token credential generate -n ${name}token${loopCount} -r ${name}
     
                        echo "======================================================================== Input Token Password Name ============================================================================"
                        read tokenPassword
                        
                        docker login ${name}.azurecr.io -u ${name}token${loopCount} -p ${tokenPassword}
                        docker tag hello-world ${name}.azurecr.io/hello-world${loopCount}
                        docker tag hello-world ${name}.azurecr.io/alpine${loopCount}
                        docker push ${name}.azurecr.io/hello-world${loopCount}
                        docker push ${name}.azurecr.io/alpine${loopCount}

                        az acr scope-map update -n ${name}scopemap${loopCount} --add alpine${loopCount} content/read content/write -r ${name}
                        docker push ${name}.azurecr.io/alpine${loopCount}

                        az acr scope-map update -n ${name}scopemap${loopCount} --add hello-world${loopCount} metadata/read -r ${name}

                        az acr repository show-manifests  --repository hello-world${loopCount} -u ${name}token${loopCount} -p ${tokenPassword} -n ${name}
                        az acr repository show-tags --repository hello-world${loopCount} -u ${name}token${loopCount} -p ${tokenPassword} -n ${name}

                        az acr scope-map update -n ${name}scopemap${loopCount} --add alpine${loopCount} metadata/write -r ${name}

                        az acr repository update --repository alpine${loopCount} --write-enabled false --delete-enabled false -u ${name}token${loopCount} -p ${tokenPassword} -n ${name}
                        az acr repository update --repository alpine${loopCount} --write-enabled true --delete-enabled true -u ${name}token${loopCount} -p ${tokenPassword} -n ${name}
                        
                        az acr scope-map update -n ${name}scopemap${loopCount} --remove alpine${loopCount} content/read -r ${name}
                        docker pull ${name}.azurecr.io/hello-world${loopCount}
                        docker pull ${name}.azurecr.io/alpine${loopCount}

                        az acr scope-map update -n ${name}scopemap${loopCount} --add alpine${loopCount} content/read -r ${name}
                        docker pull ${name}.azurecr.io/alpine${loopCount}

                        az acr scope-map update -n ${name}scopemap${loopCount} --add alpine${loopCount} content/delete -r ${name}
                        
                        az acr repository delete --repository alpine${loopCount} -u ${name}token${loopCount} -p ${tokenPassword} -n ${name}
                        
                        az acr token credential generate -n ${name}token${loopCount} -r ${name}
                        docker push ${name}.azurecr.io/alpine${loopCount}

                        docker login -u ${name}token${loopCount} -p ${tokenPassword} ${name}.azurecr.io
                        docker push ${name}.azurecr.io/alpine${loopCount}

                        az acr token update -n ${name}token${loopCount} -r ${name} --status disabled
                        docker tag hello-world ${name}a.azurecr.io/alpine${loopCount}
                        docker push ${name}a.azurecr.io/alpine${loopCount}
                        
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
        docker rmi ${name}.${name}.azurecr.io/alpine${loopCount}
        docker rmi ${name}a.${name}.azurecr.io/alpine${loopCount}
        docker rmi ${name}.${name}.azurecr.io/hello-world${loopCount}
        docker rmi ${name}.azurecr.io/newimagename${loopCount}
        docker rmi ${name}.azurecr.io/newimagename:version${loopCount}
        let "loopCount++"
done