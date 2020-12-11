
function create_namespace_if_not_exists() {
    if ! kubectl get namespaces -o json | jq -r ".items[].metadata.name" | grep $1
    then
        kubectl create namespace $1
    fi
}

