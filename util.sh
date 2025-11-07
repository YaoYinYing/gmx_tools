
# Check if a specified variable is set and has a non-empty value.
# This function takes the name of a variable as input (not its value) and verifies its existence.
# If the variable is not set or is empty, it prints an error message and exits with status 1.
# If the variable exists and has a value, it confirms the variable's presence and value.
#
# Parameters:
#   $1 (string): The name of the variable to check (passed as a string).
#
# Returns:
#   None. Exits script with error code 1 if variable is not set.
RequireVar() {
    local key_name=$1
    eval 'local checking_var_tmp=$'$key_name

    if [[ -z "${checking_var_tmp}" ]]; then
        echo "No such variable named \`${key_name}\`"
        exit 1
    else
        echo Found var ${key_name}=${checking_var_tmp}
    fi
}

CheckFile() {
    local file_to_check=$1
    if [[ ! -f "${file_to_check}" ]];then
        echo "No such file: ${traj_prefix}.xtc"
        exit 1
    fi
}

