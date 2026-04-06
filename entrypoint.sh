#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.5.1-alpha
# We cannot import `bash_version` from `env.ab` because it imports `text.ab` making a circular dependency.
# This is a workaround to avoid that issue and the import system should be improved in the future.
split__5_v0() {
    local text=$1
    local delimiter=$2
    result_22=()
    IFS="${delimiter}" read -rd '' -a result_22 < <(printf %s "$text")
    __status=$?
    ret_split5_v0=("${result_22[@]}")
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

env_var_get__101_v0() {
    local name=$1
    command_3="$(echo ${!name})"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_env_var_get101_v0=''
        return "${__status}"
    fi
    ret_env_var_get101_v0="${command_3}"
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

setup_user__126_v0() {
    local host_uid=$1
    local host_gid=$2
    local home_dir=$3
    # Check if a user with the target UID already exists
    command_4="$(getent passwd "${host_uid}" 2>/dev/null | cut -d: -f1 || true)"
    __status=$?
    existing_user_8="${command_4}"
    trim__11_v0 "${existing_user_8}"
    existing_user_8="${ret_trim11_v0}"
    if [ "$([ "_${existing_user_8}" == "_" ]; echo $?)" != 0 ]; then
        # User with this UID already exists, use it
        ret_setup_user126_v0="${existing_user_8}"
        return 0
    fi
    # Create new group and user
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
    ret_setup_user126_v0="code"
    return 0
}

setup_dirs__127_v0() {
    local home_dir=$1
    local project_dir=$2
    local user=$3
    mkdir -p "${home_dir}" "${project_dir}"
    __status=$?
    chown "${user}:${user}" "${home_dir}" >/dev/null 2>&1
    __status=$?
}

setup_sudo__128_v0() {
    local user=$1
    echo "${user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/code
    __status=$?
    chmod 0440 /etc/sudoers.d/code
    __status=$?
}

setup_git__129_v0() {
    local home_dir=$1
    local project_dir=$2
    local user=$3
    git config --global --add safe.directory "${home_dir}" >/dev/null 2>&1
    __status=$?
    git config --global --add safe.directory "${project_dir}" >/dev/null 2>&1
    __status=$?
    file_exists__40_v0 "${home_dir}/.gitconfig"
    ret_file_exists40_v0__42_12="${ret_file_exists40_v0}"
    if [ "$(( ! ${ret_file_exists40_v0__42_12} ))" != 0 ]; then
        gosu "${user}" git config --global user.name "${user}"
        __status=$?
        gosu "${user}" git config --global user.email "${user}@sandbox"
        __status=$?
    fi
}

setup_local_dirs__130_v0() {
    local home_dir=$1
    local user=$2
    mkdir -p "${home_dir}/.local/share/mise" "${home_dir}/.local/state/mise" "${home_dir}/.local/bin" "${home_dir}/.config/mise" "${home_dir}/.config/composer" "${home_dir}/.cache/mise"
    __status=$?
    chown -R "${user}:${user}" "${home_dir}/.local" "${home_dir}/.config" >/dev/null 2>&1
    __status=$?
    chown -R "${user}:${user}" "${home_dir}/.cache" >/dev/null 2>&1
    __status=$?
    dir_exists__39_v0 "/usr/local/install/global/node_modules/@just-every/code"
    ret_dir_exists39_v0__52_8="${ret_dir_exists39_v0}"
    if [ "${ret_dir_exists39_v0__52_8}" != 0 ]; then
        chown -R "${user}:${user}" "/usr/local/install/global/node_modules/@just-every/code" >/dev/null 2>&1
        __status=$?
    fi
}

setup_shadow_configs__131_v0() {
    local home_dir=$1
    local user=$2
    env_var_get__101_v0 "SANDBOX_SHADOW_CONFIGS"
    __status=$?
    if [ "${__status}" != 0 ]; then
        :
    fi
    shadow_configs_10="${ret_env_var_get101_v0}"
    if [ "$([ "_${shadow_configs_10}" != "_1" ]; echo $?)" != 0 ]; then
        env_var_get__101_v0 "SANDBOX_HOST_CONFIG_ROOT"
        __status=$?
        if [ "${__status}" != 0 ]; then
            :
        fi
        host_config_root_11="${ret_env_var_get101_v0}"
        config_dirs_12=(".codex" ".claude" ".gemini" ".opencode" ".code" ".copilot" ".agents")
        for dir_13 in "${config_dirs_12[@]}"; do
            dir_exists__39_v0 "${host_config_root_11}/${dir_13}"
            ret_dir_exists39_v0__63_16="${ret_dir_exists39_v0}"
            if [ "${ret_dir_exists39_v0__63_16}" != 0 ]; then
                mkdir -p "${home_dir}/${dir_13}"
                __status=$?
                cp -a "${host_config_root_11}/${dir_13}/." "${home_dir}/${dir_13}/"
                __status=$?
                chown -R "${user}:${user}" "${home_dir}/${dir_13}" >/dev/null 2>&1
                __status=$?
            fi
        done
        config_files_14=(".claude.json")
        for file_15 in "${config_files_14[@]}"; do
            file_exists__40_v0 "${host_config_root_11}/${file_15}"
            ret_file_exists40_v0__72_16="${ret_file_exists40_v0}"
            if [ "${ret_file_exists40_v0__72_16}" != 0 ]; then
                cp -a "${host_config_root_11}/${file_15}" "${home_dir}/${file_15}"
                __status=$?
                chown "${user}:${user}" "${home_dir}/${file_15}" >/dev/null 2>&1
                __status=$?
            fi
        done
        dir_exists__39_v0 "${host_config_root_11}/.config/opencode"
        ret_dir_exists39_v0__78_12="${ret_dir_exists39_v0}"
        if [ "${ret_dir_exists39_v0__78_12}" != 0 ]; then
            mkdir -p "${home_dir}/.config/opencode"
            __status=$?
            cp -a "${host_config_root_11}/.config/opencode/." "${home_dir}/.config/opencode/"
            __status=$?
            chown -R "${user}:${user}" "${home_dir}/.config/opencode" >/dev/null 2>&1
            __status=$?
        fi
        dir_exists__39_v0 "${host_config_root_11}/.cache/opencode"
        ret_dir_exists39_v0__84_12="${ret_dir_exists39_v0}"
        if [ "${ret_dir_exists39_v0__84_12}" != 0 ]; then
            mkdir -p "${home_dir}/.cache/opencode"
            __status=$?
            cp -a "${host_config_root_11}/.cache/opencode/." "${home_dir}/.cache/opencode/"
            __status=$?
            chown -R "${user}:${user}" "${home_dir}/.cache/opencode" >/dev/null 2>&1
            __status=$?
        fi
        dir_exists__39_v0 "${host_config_root_11}/.local/share/opencode"
        ret_dir_exists39_v0__90_12="${ret_dir_exists39_v0}"
        if [ "${ret_dir_exists39_v0__90_12}" != 0 ]; then
            mkdir -p "${home_dir}/.local/share/opencode"
            __status=$?
            cp -a "${host_config_root_11}/.local/share/opencode/." "${home_dir}/.local/share/opencode/"
            __status=$?
            chown -R "${user}:${user}" "${home_dir}/.local/share/opencode" >/dev/null 2>&1
            __status=$?
        fi
        dir_exists__39_v0 "${host_config_root_11}/.local/state/opencode"
        ret_dir_exists39_v0__96_12="${ret_dir_exists39_v0}"
        if [ "${ret_dir_exists39_v0__96_12}" != 0 ]; then
            mkdir -p "${home_dir}/.local/state/opencode"
            __status=$?
            cp -a "${host_config_root_11}/.local/state/opencode/." "${home_dir}/.local/state/opencode/"
            __status=$?
            chown -R "${user}:${user}" "${home_dir}/.local/state/opencode" >/dev/null 2>&1
            __status=$?
        fi
    fi
}

setup_bashrc__132_v0() {
    local home_dir=$1
    local user=$2
    bashrc_16="${home_dir}/.bashrc"
    has_mise_17=1
    grep -q "mise activate" "${bashrc_16}" >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        has_mise_17=0
    fi
    if [ "$(( ! ${has_mise_17} ))" != 0 ]; then
        # Write the mise activation line
        # Double backslash so one survives compilation, %b interprets \\044 as $
        printf 'eval "\044(mise activate bash)"
' >> "${bashrc_16}"
        __status=$?
        chown "${user}:${user}" "${bashrc_16}" >/dev/null 2>&1
        __status=$?
    fi
}

setup_code_symlink__133_v0() {
    local home_dir=$1
    local user=$2
    is_command__103_v0 "code"
    ret_is_command103_v0__119_12="${ret_is_command103_v0}"
    if [ "$(( ! ${ret_is_command103_v0__119_12} ))" != 0 ]; then
        is_command__103_v0 "coder"
        ret_is_command103_v0__120_12="${ret_is_command103_v0}"
        if [ "${ret_is_command103_v0__120_12}" != 0 ]; then
            command_7="$(command -v coder)"
            __status=$?
            coder_path_20="${command_7}"
            ln -sf "${coder_path_20}" "${home_dir}/.local/bin/code"
            __status=$?
            chown "${user}:${user}" "${home_dir}/.local/bin/code" >/dev/null 2>&1
            __status=$?
        fi
    fi
}

setup_mise_env__134_v0() {
    local home_dir=$1
    local project_dir=$2
    trusted_paths_19="${home_dir}:${home_dir}/.config/mise:${home_dir}/.config/mise/config.toml:${project_dir}:${project_dir}/.mise.toml:${project_dir}/mise.toml"
    export XDG_CACHE_HOME="${home_dir}/.cache"
    __status=$?
    export XDG_STATE_HOME="${home_dir}/.local/state"
    __status=$?
    export MISE_CACHE_DIR="${home_dir}/.cache/mise"
    __status=$?
    export MISE_STATE_DIR="${home_dir}/.local/state/mise"
    __status=$?
    export MISE_GLOBAL_CONFIG_FILE="${home_dir}/.config/mise/config.toml"
    __status=$?
    export MISE_GLOBAL_CONFIG_ROOT="${home_dir}"
    __status=$?
    export MISE_TRUSTED_CONFIG_PATHS="${trusted_paths_19}"
    __status=$?
    export MISE_YES=1
    __status=$?
}

install_php__135_v0() {
    local home_dir=$1
    local user=$2
    gosu "${user}" env HOME="${home_dir}" mise use -g github:aaronflorey/php@8.4 >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        # Corrupted cached archives can cause "invalid gzip header" errors.
        # Clear cached/downloaded PHP artifacts and retry once.
        rm -rf "${home_dir}/.local/share/mise/downloads/github-aaronflorey-php" "${home_dir}/.local/share/mise/installs/github-aaronflorey-php"
        __status=$?
        gosu "${user}" env HOME="${home_dir}" mise use -g github:aaronflorey/php@8.4
        __status=$?
    fi
}

install_languages__136_v0() {
    local sandbox_languages=$1
    local project_dir=$2
    local home_dir=$3
    local user=$4
    if [ "$([ "_${sandbox_languages}" != "___mise_toml__" ]; echo $?)" != 0 ]; then
        echo "Installing languages from .mise.toml ..."
        cd "${project_dir}"
        __status=$?
        gosu "${user}" env HOME="${home_dir}" mise install -y
        __status=$?
        gosu "${user}" env HOME="${home_dir}" mise reshim
        __status=$?
    else
        split__5_v0 "${sandbox_languages}" ","
        langs_23=("${ret_split5_v0[@]}")
        for lang_24 in "${langs_23[@]}"; do
            trim__11_v0 "${lang_24}"
            l_25="${ret_trim11_v0}"
            if [ "$([ "_${l_25}" != "_" ]; echo $?)" != 0 ]; then
                continue
            fi
            if [ "$([ "_${l_25}" != "_all" ]; echo $?)" != 0 ]; then
                echo "Installing all languages via mise (php, go, rust, ruby, java, python, zig, erlang, elixir) ..."
                install_php__135_v0 "${home_dir}" "${user}"
                gosu "${user}" env HOME="${home_dir}" mise use -g go@latest rust@latest ruby@latest java@latest python@latest zig@latest erlang@latest elixir@latest
                __status=$?
                gosu "${user}" env HOME="${home_dir}" mise reshim
                __status=$?
                break
            fi
            if [ "$(( $(( $(( $(( $(( $(( $(( $(( $([ "_${l_25}" != "_php" ]; echo $?) || $([ "_${l_25}" != "_go" ]; echo $?) )) || $([ "_${l_25}" != "_rust" ]; echo $?) )) || $([ "_${l_25}" != "_ruby" ]; echo $?) )) || $([ "_${l_25}" != "_java" ]; echo $?) )) || $([ "_${l_25}" != "_python" ]; echo $?) )) || $([ "_${l_25}" != "_zig" ]; echo $?) )) || $([ "_${l_25}" != "_erlang" ]; echo $?) )) || $([ "_${l_25}" != "_elixir" ]; echo $?) ))" != 0 ]; then
                echo "Installing ${l_25} via mise ..."
                if [ "$([ "_${l_25}" != "_php" ]; echo $?)" != 0 ]; then
                    install_php__135_v0 "${home_dir}" "${user}"
                else
                    gosu "${user}" env HOME="${home_dir}" mise use -g "${l_25}@latest"
                    __status=$?
                fi
            else
                echo "Unknown language: ${l_25} (skipping)"
            fi
        done
        gosu "${user}" env HOME="${home_dir}" mise reshim
        __status=$?
    fi
}

install_composer__137_v0() {
    local home_dir=$1
    local user=$2
    php_available_26=1
    gosu "${user}" env HOME="${home_dir}" mise which php >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        php_available_26=0
    fi
    is_command__103_v0 "composer"
    ret_is_command103_v0__190_30="${ret_is_command103_v0}"
    if [ "$(( ${php_available_26} && $(( ! ${ret_is_command103_v0__190_30} )) ))" != 0 ]; then
        echo "Installing Composer ..."
        gosu "${user}" env HOME="${home_dir}" curl -fsSL "https://getcomposer.org/download/latest-stable/composer.phar" -o "${home_dir}/.local/bin/composer"
        __status=$?
        chmod +x "${home_dir}/.local/bin/composer"
        __status=$?
        chown "${user}:${user}" "${home_dir}/.local/bin/composer" >/dev/null 2>&1
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
if [ "$([ "_${project_dir_7}" != "_" ]; echo $?)" != 0 ]; then
    project_dir_7="/workspace"
fi
export HOME="${home_dir_6}"
__status=$?
setup_user__126_v0 "${host_uid_4}" "${host_gid_5}" "${home_dir_6}"
user_9="${ret_setup_user126_v0}"
setup_dirs__127_v0 "${home_dir_6}" "${project_dir_7}" "${user_9}"
setup_sudo__128_v0 "${user_9}"
setup_git__129_v0 "${home_dir_6}" "${project_dir_7}" "${user_9}"
setup_local_dirs__130_v0 "${home_dir_6}" "${user_9}"
setup_shadow_configs__131_v0 "${home_dir_6}" "${user_9}"
setup_bashrc__132_v0 "${home_dir_6}" "${user_9}"
env_var_get__101_v0 "PATH"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
current_path_18="${ret_env_var_get101_v0}"
export PATH="${home_dir_6}/.local/share/mise/shims:${home_dir_6}/.local/bin:/usr/local/bun/bin:${current_path_18}"
__status=$?
setup_mise_env__134_v0 "${home_dir_6}" "${project_dir_7}"
setup_code_symlink__133_v0 "${home_dir_6}" "${user_9}"
env_var_get__101_v0 "SANDBOX_LANGUAGES"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
sandbox_languages_21="${ret_env_var_get101_v0}"
if [ "$([ "_${sandbox_languages_21}" == "_" ]; echo $?)" != 0 ]; then
    install_languages__136_v0 "${sandbox_languages_21}" "${project_dir_7}" "${home_dir_6}" "${user_9}"
fi
install_composer__137_v0 "${home_dir_6}" "${user_9}"
export COLORTERM=truecolor
__status=$?
export FORCE_COLOR=1
__status=$?
dir_exists__39_v0 "${project_dir_7}"
ret_dir_exists39_v0__233_8="${ret_dir_exists39_v0}"
if [ "${ret_dir_exists39_v0__233_8}" != 0 ]; then
    cd "${project_dir_7}"
    __status=$?
fi
# Exec with env HOME to preserve our home directory setting after gosu
# Use "$@" to preserve argument quoting
exec gosu "${user_9}" env HOME="${home_dir_6}" "$@"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
