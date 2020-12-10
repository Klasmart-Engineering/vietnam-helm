function env_terraform_init_var() {
    ENV="$1"
    JSON=$(env_path "$ENV" "$ENUM_TERRAFORM_INIT_FILE")
    VAR=$(cat "$JSON" | jq -r ".$2")
    echo "$VAR"
}

function env_path {
    ENV="$1"
    FILE="$2"
    echo "../env/$1/$2"
}

function env_validate_file {

    ENV="$1"
    FILE="$2"
    JSON="$(env_path "$ENV" "$FILE")"

    if [ -z "$ENV" ]
    then
        echo "Please ensure you provide an ENV variable"
        exit 1

    elif [ ! -f "$JSON"  ]
    then
        echo "Please ensure your env ($ENV) contains the file: $FILE"
        exit 1

    fi
} 


function echo_terraform_params {
    echo -e "\nPROVIDER:    $1\nENVIRONMENT: $2\nTFVARS:      $3"
    echo_line 
}

function echo_line {
   echo ------------------------------------------------------------------------
}