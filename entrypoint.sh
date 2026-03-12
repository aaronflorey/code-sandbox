#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.5.1-alpha
# We cannot import `bash_version` from `env.ab` because it imports `text.ab` making a circular dependency.
# This is a workaround to avoid that issue and the import system should be improved in the future.
split__5_v0() {
    local text=$1
    local delimiter=$2
    result_13=()
    IFS="${delimiter}" read -rd '' -a result_13 < <(printf %s "$text")
    __status=$?
    ret_split5_v0=("${result_13[@]}")
    return 0
}

trim_left__9_v0() {
    local text=$1
    command_1="$(echo "${text}" | sed -e 's/^[[:space:]]*//')"
    __status=$?
    ret_trim_left9_v0="${command_1}"
    return 0
}

trim_right__10_v0() {
    local text=$1
    command_2="$(echo "${text}" | sed -e 's/[[:space:]]*$//')"
    __status=$?
    ret_trim_right10_v0="${command_2}"
    return 0
}

trim__11_v0() {
    local text=$1
    trim_right__10_v0 "${text}"
    ret_trim_right10_v0__178_22="${ret_trim_right10_v0}"
    trim_left__9_v0 "${ret_trim_right10_v0__178_22}"
    ret_trim11_v0="${ret_trim_left9_v0}"
    return 0
}

dir_exists__39_v0() {
    local path=$1
    [ -d "${path}" ]
    __status=$?
    ret_dir_exists39_v0="$(( ${__status} == 0 ))"
    return 0
}

file_exists__40_v0() {
    local path=$1
    [ -f "${path}" ]
    __status=$?
    ret_file_exists40_v0="$(( ${__status} == 0 ))"
    return 0
}

file_append__43_v0() {
    local path=$1
    local content=$2
    command_3="$(echo "${content}" >> "${path}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_file_append43_v0=''
        return "${__status}"
    fi
    ret_file_append43_v0="${command_3}"
    return 0
}

env_var_get__101_v0() {
    local name=$1
    command_4="$(echo ${!name})"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_env_var_get101_v0=''
        return "${__status}"
    fi
    ret_env_var_get101_v0="${command_4}"
    return 0
}

is_command__103_v0() {
    local command=$1
    [ -x "$(command -v "${command}")" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_is_command103_v0=0
        return 0
    fi
    ret_is_command103_v0=1
    return 0
}

collect_args__126_v0() {
    local args=("${!1}")
    local start=$2
    result_18=""
    i_19="${start}"
    while :
    do
        __length_5=("${args[@]}")
        if [ "$(( ${i_19} >= ${#__length_5[@]} ))" != 0 ]; then
            break
        fi
        if [ "$([ "_${result_18}" == "_" ]; echo $?)" != 0 ]; then
            result_18+=" "
        fi
        result_18+="${args[${i_19}]}"
        i_19="$(( ${i_19} + 1 ))"
    done
    ret_collect_args126_v0="${result_18}"
    return 0
}

setup_user__127_v0() {
    local host_uid=$1
    local host_gid=$2
    local home_dir=$3
    getent group code >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        groupadd -g "${host_gid}" code >/dev/null 2>&1
        __status=$?
        if [ "${__status}" != 0 ]; then
            groupadd code >/dev/null 2>&1
            __status=$?
        fi
    fi
    id code >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        useradd -m -d "${home_dir}" -u "${host_uid}" -g code -s /bin/bash code >/dev/null 2>&1
        __status=$?
        if [ "${__status}" != 0 ]; then
            useradd -m -d "${home_dir}" -g code -s /bin/bash code >/dev/null 2>&1
            __status=$?
        fi
    fi
}

setup_dirs__128_v0() {
    local home_dir=$1
    local project_dir=$2
    mkdir -p "${home_dir}" "${project_dir}"
    __status=$?
    chown code:code "${home_dir}" >/dev/null 2>&1
    __status=$?
}

setup_sudo__129_v0() {
    echo "code ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/code
    __status=$?
    chmod 0440 /etc/sudoers.d/code
    __status=$?
}

setup_git__130_v0() {
    local home_dir=$1
    local project_dir=$2
    git config --global --add safe.directory "${home_dir}" >/dev/null 2>&1
    __status=$?
    git config --global --add safe.directory "${project_dir}" >/dev/null 2>&1
    __status=$?
    file_exists__40_v0 "${home_dir}/.gitconfig"
    ret_file_exists40_v0__43_12="${ret_file_exists40_v0}"
    if [ "$(( ! ${ret_file_exists40_v0__43_12} ))" != 0 ]; then
        gosu code git config --global user.name "code"
        __status=$?
        gosu code git config --global user.email "code@sandbox"
        __status=$?
    fi
}

setup_local_dirs__131_v0() {
    local home_dir=$1
    mkdir -p "${home_dir}/.local/share/mise" "${home_dir}/.local/bin" "${home_dir}/.config/mise" "${home_dir}/.config/composer"
    __status=$?
    chown -R code:code "${home_dir}/.local" "${home_dir}/.config" >/dev/null 2>&1
    __status=$?
    dir_exists__39_v0 "/usr/local/install/global/node_modules/@just-every/code"
    ret_dir_exists39_v0__52_8="${ret_dir_exists39_v0}"
    if [ "${ret_dir_exists39_v0__52_8}" != 0 ]; then
        chown -R code:code "/usr/local/install/global/node_modules/@just-every/code" >/dev/null 2>&1
        __status=$?
    fi
}

setup_bashrc__132_v0() {
    local home_dir=$1
    bashrc_8="${home_dir}/.bashrc"
    has_mise_9=1
    grep -q "mise activate" "${bashrc_8}" >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        has_mise_9=0
    fi
    if [ "$(( ! ${has_mise_9} ))" != 0 ]; then
        # \$ writes a literal $ so bash sources the file with eval "$(mise activate bash)" intact
        file_append__43_v0 "${bashrc_8}" "eval \"\\\$(mise activate bash)\"
"
        __status=$?
        chown code:code "${bashrc_8}" >/dev/null 2>&1
        __status=$?
    fi
}

setup_code_symlink__133_v0() {
    local home_dir=$1
    is_command__103_v0 "code"
    ret_is_command103_v0__71_12="${ret_is_command103_v0}"
    if [ "$(( ! ${ret_is_command103_v0__71_12} ))" != 0 ]; then
        is_command__103_v0 "coder"
        ret_is_command103_v0__72_12="${ret_is_command103_v0}"
        if [ "${ret_is_command103_v0__72_12}" != 0 ]; then
            command_6="$(command -v coder)"
            __status=$?
            coder_path_11="${command_6}"
            ln -sf "${coder_path_11}" "${home_dir}/.local/bin/code"
            __status=$?
            chown code:code "${home_dir}/.local/bin/code" >/dev/null 2>&1
            __status=$?
        fi
    fi
}

install_languages__134_v0() {
    local sandbox_languages=$1
    local project_dir=$2
    if [ "$([ "_${sandbox_languages}" != "___mise_toml__" ]; echo $?)" != 0 ]; then
        echo "Installing languages from .mise.toml ..."
        cd "${project_dir}"
        __status=$?
        gosu code mise install -y
        __status=$?
        gosu code mise reshim
        __status=$?
    else
        split__5_v0 "${sandbox_languages}" ","
        langs_14=("${ret_split5_v0[@]}")
        for lang_15 in "${langs_14[@]}"; do
            trim__11_v0 "${lang_15}"
            l_16="${ret_trim11_v0}"
            if [ "$([ "_${l_16}" != "_" ]; echo $?)" != 0 ]; then
                continue
            fi
            if [ "$([ "_${l_16}" != "_all" ]; echo $?)" != 0 ]; then
                echo "Installing all languages via mise (php, go, rust, ruby, java, python, zig, erlang, elixir) ..."
                gosu code mise use -g github:adwinying/php@8.4 go@latest rust@latest ruby@latest java@latest python@latest zig@latest erlang@latest elixir@latest
                __status=$?
                gosu code mise reshim
                __status=$?
                break
            fi
            if [ "$(( $(( $(( $(( $(( $(( $(( $(( $([ "_${l_16}" != "_php" ]; echo $?) || $([ "_${l_16}" != "_go" ]; echo $?) )) || $([ "_${l_16}" != "_rust" ]; echo $?) )) || $([ "_${l_16}" != "_ruby" ]; echo $?) )) || $([ "_${l_16}" != "_java" ]; echo $?) )) || $([ "_${l_16}" != "_python" ]; echo $?) )) || $([ "_${l_16}" != "_zig" ]; echo $?) )) || $([ "_${l_16}" != "_erlang" ]; echo $?) )) || $([ "_${l_16}" != "_elixir" ]; echo $?) ))" != 0 ]; then
                echo "Installing ${l_16} via mise ..."
                if [ "$([ "_${l_16}" != "_php" ]; echo $?)" != 0 ]; then
                    gosu code mise use -g github:adwinying/php@8.4
                    __status=$?
                else
                    gosu code mise use -g "${l_16}@latest"
                    __status=$?
                fi
            else
                echo "Unknown language: ${l_16} (skipping)"
            fi
        done
        gosu code mise reshim
        __status=$?
    fi
}

install_composer__135_v0() {
    local home_dir=$1
    php_available_17=1
    gosu code mise which php >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        php_available_17=0
    fi
    is_command__103_v0 "composer"
    ret_is_command103_v0__120_30="${ret_is_command103_v0}"
    if [ "$(( ${php_available_17} && $(( ! ${ret_is_command103_v0__120_30} )) ))" != 0 ]; then
        echo "Installing Composer ..."
        gosu code mise use -g github:composer/composer
        __status=$?
        gosu code mise reshim
        __status=$?
    fi
}

declare -r args_3=("$0" "$@")
env_var_get__101_v0 "HOST_UID"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
host_uid_4="${ret_env_var_get101_v0}"
env_var_get__101_v0 "HOST_GID"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
host_gid_5="${ret_env_var_get101_v0}"
home_dir_6="/workspace"
env_var_get__101_v0 "SANDBOX_PROJECT_DIR"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
project_dir_7="${ret_env_var_get101_v0}"
export HOME="${home_dir_6}"
__status=$?
setup_user__127_v0 "${host_uid_4}" "${host_gid_5}" "${home_dir_6}"
setup_dirs__128_v0 "${home_dir_6}" "${project_dir_7}"
setup_sudo__129_v0 
setup_git__130_v0 "${home_dir_6}" "${project_dir_7}"
setup_local_dirs__131_v0 "${home_dir_6}"
setup_bashrc__132_v0 "${home_dir_6}"
env_var_get__101_v0 "PATH"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
current_path_10="${ret_env_var_get101_v0}"
export PATH="${home_dir_6}/.local/share/mise/shims:${home_dir_6}/.local/bin:/usr/local/bun/bin:${current_path_10}"
__status=$?
setup_code_symlink__133_v0 "${home_dir_6}"
env_var_get__101_v0 "SANDBOX_LANGUAGES"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
sandbox_languages_12="${ret_env_var_get101_v0}"
if [ "$([ "_${sandbox_languages_12}" == "_" ]; echo $?)" != 0 ]; then
    install_languages__134_v0 "${sandbox_languages_12}" "${project_dir_7}"
fi
install_composer__135_v0 "${home_dir_6}"
export COLORTERM=truecolor
__status=$?
export FORCE_COLOR=1
__status=$?
dir_exists__39_v0 "${project_dir_7}"
ret_dir_exists39_v0__157_8="${ret_dir_exists39_v0}"
if [ "${ret_dir_exists39_v0__157_8}" != 0 ]; then
    cd "${project_dir_7}"
    __status=$?
fi
collect_args__126_v0 args_3[@] 1
cmd_20="${ret_collect_args126_v0}"
exec gosu code ${cmd_20}
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
