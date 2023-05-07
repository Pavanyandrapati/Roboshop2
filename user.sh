script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
func_nodejs

component = user
func_nodejs
schema_setup = mongo


