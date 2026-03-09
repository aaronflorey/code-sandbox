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

uppercase__13_v0() {
    local text=$1
    command_3="$(echo "${text}" | tr '[:lower:]' '[:upper:]')"
    __status=$?
    ret_uppercase13_v0="${command_3}"
    return 0
}

rpad__29_v0() {
    local text=$1
    local pad=$2
    local length=$3
    __length_4="${text}"
    if [ "$(( ${length} <= ${#__length_4} ))" != 0 ]; then
        ret_rpad29_v0="${text}"
        return 0
    fi
    __length_5="${text}"
    length="$(( ${#__length_5} - ${length} ))"
    command_6="$(printf "%${length}s" "" | tr " " "${pad}")"
    __status=$?
    pad="${command_6}"
    ret_rpad29_v0="${text}""${pad}"
    return 0
}

dir_exists__40_v0() {
    local path=$1
    [ -d "${path}" ]
    __status=$?
    ret_dir_exists40_v0="$(( ${__status} == 0 ))"
    return 0
}

file_exists__41_v0() {
    local path=$1
    [ -f "${path}" ]
    __status=$?
    ret_file_exists41_v0="$(( ${__status} == 0 ))"
    return 0
}

file_append__44_v0() {
    local path=$1
    local content=$2
    command_7="$(echo "${content}" >> "${path}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_file_append44_v0=''
        return "${__status}"
    fi
    ret_file_append44_v0="${command_7}"
    return 0
}

env_var_get__102_v0() {
    local name=$1
    command_8="$(echo ${!name})"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_env_var_get102_v0=''
        return "${__status}"
    fi
    ret_env_var_get102_v0="${command_8}"
    return 0
}

is_command__104_v0() {
    local command=$1
    [ -x "$(command -v "${command}")" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_is_command104_v0=0
        return 0
    fi
    ret_is_command104_v0=1
    return 0
}

collect_args__127_v0() {
    local args=("${!1}")
    local start=$2
    result_25=""
    i_26="${start}"
    while :
    do
        __length_9=("${args[@]}")
        if [ "$(( ${i_26} >= ${#__length_9[@]} ))" != 0 ]; then
            break
        fi
        if [ "$([ "_${result_25}" == "_" ]; echo $?)" != 0 ]; then
            result_25+=" "
        fi
        result_25+="${args[${i_26}]}"
        i_26="$(( ${i_26} + 1 ))"
    done
    ret_collect_args127_v0="${result_25}"
    return 0
}

setup_user__128_v0() {
    local host_uid=$1
    local host_gid=$2
    local home_dir=$3
    getent group code >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        groupadd -g "${host_gid}" code
        __status=$?
        if [ "${__status}" != 0 ]; then
            groupadd code
            __status=$?
        fi
    fi
    id code >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        useradd -m -d "${home_dir}" -u "${host_uid}" -g code -s /bin/bash code
        __status=$?
        if [ "${__status}" != 0 ]; then
            useradd -m -d "${home_dir}" -g code -s /bin/bash code
            __status=$?
        fi
    fi
}

setup_dirs__129_v0() {
    local home_dir=$1
    local project_dir=$2
    mkdir -p "${home_dir}" "${project_dir}"
    __status=$?
    chown code:code "${home_dir}" >/dev/null 2>&1
    __status=$?
}

setup_sudo__130_v0() {
    echo "code ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/code
    __status=$?
    chmod 0440 /etc/sudoers.d/code
    __status=$?
}

setup_git__131_v0() {
    local home_dir=$1
    local project_dir=$2
    git config --global --add safe.directory "${home_dir}" >/dev/null 2>&1
    __status=$?
    git config --global --add safe.directory "${project_dir}" >/dev/null 2>&1
    __status=$?
    file_exists__41_v0 "${home_dir}/.gitconfig"
    ret_file_exists41_v0__43_12="${ret_file_exists41_v0}"
    if [ "$(( ! ${ret_file_exists41_v0__43_12} ))" != 0 ]; then
        gosu code git config --global user.name "code"
        __status=$?
        gosu code git config --global user.email "code@sandbox"
        __status=$?
    fi
}

setup_local_dirs__132_v0() {
    local home_dir=$1
    mkdir -p "${home_dir}/.local/share/mise" "${home_dir}/.local/bin" "${home_dir}/.config/mise" "${home_dir}/.config/composer"
    __status=$?
    chown -R code:code "${home_dir}/.local" "${home_dir}/.config" >/dev/null 2>&1
    __status=$?
    dir_exists__40_v0 "/usr/local/install/global/node_modules/@just-every/code"
    ret_dir_exists40_v0__52_8="${ret_dir_exists40_v0}"
    if [ "${ret_dir_exists40_v0__52_8}" != 0 ]; then
        chown -R code:code "/usr/local/install/global/node_modules/@just-every/code" >/dev/null 2>&1
        __status=$?
    fi
}

setup_bashrc__133_v0() {
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
        file_append__44_v0 "${bashrc_8}" "eval \"\\\$(mise activate bash)\"
"
        __status=$?
        chown code:code "${bashrc_8}" >/dev/null 2>&1
        __status=$?
    fi
}

setup_code_symlink__134_v0() {
    local home_dir=$1
    is_command__104_v0 "code"
    ret_is_command104_v0__71_12="${ret_is_command104_v0}"
    if [ "$(( ! ${ret_is_command104_v0__71_12} ))" != 0 ]; then
        is_command__104_v0 "coder"
        ret_is_command104_v0__72_12="${ret_is_command104_v0}"
        if [ "${ret_is_command104_v0__72_12}" != 0 ]; then
            command_10="$(command -v coder)"
            __status=$?
            coder_path_11="${command_10}"
            ln -sf "${coder_path_11}" "${home_dir}/.local/bin/code"
            __status=$?
            chown code:code "${home_dir}/.local/bin/code" >/dev/null 2>&1
            __status=$?
        fi
    fi
}

install_languages__135_v0() {
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
                gosu code mise use -g php@latest go@latest rust@latest ruby@latest java@latest python@latest zig@latest erlang@latest elixir@latest
                __status=$?
                gosu code mise reshim
                __status=$?
                break
            fi
            if [ "$(( $(( $(( $(( $(( $(( $(( $(( $([ "_${l_16}" != "_php" ]; echo $?) || $([ "_${l_16}" != "_go" ]; echo $?) )) || $([ "_${l_16}" != "_rust" ]; echo $?) )) || $([ "_${l_16}" != "_ruby" ]; echo $?) )) || $([ "_${l_16}" != "_java" ]; echo $?) )) || $([ "_${l_16}" != "_python" ]; echo $?) )) || $([ "_${l_16}" != "_zig" ]; echo $?) )) || $([ "_${l_16}" != "_erlang" ]; echo $?) )) || $([ "_${l_16}" != "_elixir" ]; echo $?) ))" != 0 ]; then
                echo "Installing ${l_16} via mise ..."
                gosu code mise use -g "${l_16}@latest"
                __status=$?
            else
                echo "Unknown language: ${l_16} (skipping)"
            fi
        done
        gosu code mise reshim
        __status=$?
    fi
}

install_composer__136_v0() {
    local home_dir=$1
    php_available_17=1
    gosu code mise which php >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        php_available_17=0
    fi
    is_command__104_v0 "composer"
    ret_is_command104_v0__116_30="${ret_is_command104_v0}"
    if [ "$(( ${php_available_17} && $(( ! ${ret_is_command104_v0__116_30} )) ))" != 0 ]; then
        echo "Installing Composer ..."
        curl -sS https://getcomposer.org/installer | gosu code php -- --install-dir="${home_dir}/.local/bin" --filename=composer
        __status=$?
    fi
}

setup_sandbox__137_v0() {
    local project_dir=$1
    git -C "${project_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_setup_sandbox137_v0=""
        return 0
    fi
    command_11="$(basename "${project_dir}")"
    __status=$?
    proj_name_18="${command_11}"
    sandbox_work_dir_19="/tmp/sandbox/${proj_name_18}"
    rpad__29_v0 "${proj_name_18}" " " 40
    padded_20="${ret_rpad29_v0}"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│  🛡️  Safe Mode: isolated sandbox workspace                       │"
    echo "│                                                                  │"
    echo "│  Git repo detected. The agent will work in an isolated copy     │"
    echo "│  of your project — your workspace files stay untouched until    │"
    echo "│  you decide what to do when the session ends.                   │"
    echo "│                                                                  │"
    echo "│  Sandbox : /tmp/sandbox/${padded_20}│"
    echo "│  On exit : you will be asked what to do with any changes.       │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
    mkdir -p /tmp/sandbox
    __status=$?
    chown code:code /tmp/sandbox
    __status=$?
    gosu code git clone --quiet "${project_dir}" "${sandbox_work_dir_19}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Warning: git clone failed — falling back to direct workspace."
        echo ""
        ret_setup_sandbox137_v0=""
        return 0
    fi
    gosu code rsync -a --exclude=.git "${project_dir}/" "${sandbox_work_dir_19}/"
    __status=$?
    gosu code git -C "${sandbox_work_dir_19}" remote set-url origin "${project_dir}" >/dev/null 2>&1
    __status=$?
    # Check for any dirty state: unstaged, staged, or untracked files
    has_diff_21=0
    gosu code git -C "${sandbox_work_dir_19}" diff --quiet >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        has_diff_21=1
    fi
    has_cached_22=0
    gosu code git -C "${sandbox_work_dir_19}" diff --cached --quiet >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        has_cached_22=1
    fi
    command_12="$(gosu code git -C "${sandbox_work_dir_19}" ls-files --others --exclude-standard)"
    __status=$?
    untracked_23="${command_12}"
    if [ "$(( $(( ${has_diff_21} || ${has_cached_22} )) || $([ "_${untracked_23}" == "_" ]; echo $?) ))" != 0 ]; then
        gosu code git -C "${sandbox_work_dir_19}" add -A
        __status=$?
        gosu code git -C "${sandbox_work_dir_19}" commit -m "pre-sandbox: uncommitted host changes" --quiet >/dev/null 2>&1
        __status=$?
    fi
    ret_setup_sandbox137_v0="${sandbox_work_dir_19}"
    return 0
}

sandbox_exit__138_v0() {
    local sandbox_work_dir=$1
    local project_dir=$2
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│  🛡️  Sandbox session ended — what should happen to the changes? │"
    echo "│                                                                  │"
    echo "│  A) Copy changes → workspace   (additive rsync, safe)          │"
    echo "│  B) Mirror sandbox → workspace (rsync --delete, may remove)    │"
    echo "│  C) Create new branch in workspace with the sandbox changes     │"
    echo "│  D) Discard — leave workspace exactly as it was                 │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
    # Read from /dev/tty to ensure we get terminal input even if stdin is piped
    command_13="$(if [ -t 0 ]; then read -r -p "Choice [A/B/C/D]: " _c </dev/tty 2>/dev/tty || _c="D"; else _c="D"; fi; echo "$_c")"
    __status=$?
    choice_30="${command_13}"
    uppercase__13_v0 "${choice_30}"
    choice_upper_31="${ret_uppercase13_v0}"
    if [ "$([ "_${choice_upper_31}" != "_A" ]; echo $?)" != 0 ]; then
        echo "→ Copying sandbox changes to workspace (additive)..."
        rsync -a --exclude=.git "${sandbox_work_dir}/" "${project_dir}/"
        __status=$?
        echo "✓ Done."
    elif [ "$([ "_${choice_upper_31}" != "_B" ]; echo $?)" != 0 ]; then
        echo "→ Mirroring sandbox to workspace (adds + deletes)..."
        rsync -a --delete --exclude=.git "${sandbox_work_dir}/" "${project_dir}/"
        __status=$?
        echo "✓ Done."
    elif [ "$([ "_${choice_upper_31}" != "_C" ]; echo $?)" != 0 ]; then
        command_14="$(echo "sandbox/$(date +%Y%m%d-%H%M%S)")"
        __status=$?
        branch_32="${command_14}"
        echo "→ Creating branch ${branch_32}..."
        gosu code git -C "${sandbox_work_dir}" add -A
        __status=$?
        gosu code git -C "${sandbox_work_dir}" diff --cached --quiet >/dev/null 2>&1
        __status=$?
        if [ "${__status}" != 0 ]; then
            gosu code git -C "${sandbox_work_dir}" commit -m "sandbox: agent changes" --quiet
            __status=$?
        fi
        push_failed_33=0
        gosu code git -C "${sandbox_work_dir}" push origin "HEAD:refs/heads/${branch_32}" --quiet
        __status=$?
        if [ "${__status}" != 0 ]; then
            push_failed_33=1
        fi
        if [ "${push_failed_33}" != 0 ]; then
            echo "✗ Branch push failed — falling back to additive rsync..."
            rsync -a --exclude=.git "${sandbox_work_dir}/" "${project_dir}/"
            __status=$?
            echo "✓ Changes copied to workspace instead."
        else
            echo "✓ Branch '${branch_32}' created in workspace."
            echo "  Switch to it with: git checkout ${branch_32}"
        fi
    else
        echo "→ Workspace unchanged."
    fi
}

declare -r args_3=("$0" "$@")
env_var_get__102_v0 "HOST_UID"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
host_uid_4="${ret_env_var_get102_v0}"
env_var_get__102_v0 "HOST_GID"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
host_gid_5="${ret_env_var_get102_v0}"
home_dir_6="/workspace"
env_var_get__102_v0 "SANDBOX_PROJECT_DIR"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
project_dir_7="${ret_env_var_get102_v0}"
export HOME="${home_dir_6}"
__status=$?
setup_user__128_v0 "${host_uid_4}" "${host_gid_5}" "${home_dir_6}"
setup_dirs__129_v0 "${home_dir_6}" "${project_dir_7}"
setup_sudo__130_v0 
setup_git__131_v0 "${home_dir_6}" "${project_dir_7}"
setup_local_dirs__132_v0 "${home_dir_6}"
setup_bashrc__133_v0 "${home_dir_6}"
env_var_get__102_v0 "PATH"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
current_path_10="${ret_env_var_get102_v0}"
export PATH="${home_dir_6}/.local/share/mise/shims:${home_dir_6}/.local/bin:/usr/local/bun/bin:${current_path_10}"
__status=$?
setup_code_symlink__134_v0 "${home_dir_6}"
env_var_get__102_v0 "SANDBOX_LANGUAGES"
__status=$?
if [ "${__status}" != 0 ]; then
    :
fi
sandbox_languages_12="${ret_env_var_get102_v0}"
if [ "$([ "_${sandbox_languages_12}" == "_" ]; echo $?)" != 0 ]; then
    install_languages__135_v0 "${sandbox_languages_12}" "${project_dir_7}"
fi
install_composer__136_v0 "${home_dir_6}"
export COLORTERM=truecolor
__status=$?
export FORCE_COLOR=1
__status=$?
setup_sandbox__137_v0 "${project_dir_7}"
sandbox_work_dir_24="${ret_setup_sandbox137_v0}"
collect_args__127_v0 args_3[@] 1
cmd_27="${ret_collect_args127_v0}"
if [ "$([ "_${sandbox_work_dir_24}" == "_" ]; echo $?)" != 0 ]; then
    cd "${sandbox_work_dir_24}"
    __status=$?
    agent_exit_28=0
    gosu code ${cmd_27}
    __status=$?
    if [ "${__status}" != 0 ]; then
    code_29="${__status}"
        agent_exit_28="${code_29}"
    fi
    sandbox_exit__138_v0 "${sandbox_work_dir_24}" "${project_dir_7}"
    exit ${agent_exit_28}
    __status=$?
else
    dir_exists__40_v0 "${project_dir_7}"
    ret_dir_exists40_v0__269_12="${ret_dir_exists40_v0}"
    if [ "${ret_dir_exists40_v0__269_12}" != 0 ]; then
        cd "${project_dir_7}"
        __status=$?
    fi
    exec gosu code ${cmd_27}
    __status=$?
    if [ "${__status}" != 0 ]; then
        exit "${__status}"
    fi
fi
