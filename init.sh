
#!/bin/bash

# General variables
if grep -q "WSL" /proc/sys/kernel/osrelease; then
    etc_hosts=$(wslpath -u 'C:\Windows\System32\drivers\etc\hosts')
else
    etc_hosts='/etc/hosts'
fi

explicit_selection=false
tools=(rustscan dirb nikto ffuf nmap html_comments)

declare -A args=(
    ["verbose"]=false
    ["dryrun"]=false
    ["ip"]=""
    ["host"]=""
    ["http"]="http"
    ["http_port"]="80"
    ["scan_mode"]="tcp"
    ["user_ag"]=""
    ["cookie"]=""
    # These arguments are only used if user choose its tool
    ["rustscan"]=false
    ["rustscan_opts"]=""
    ["nmap"]=false
    ["nmap_opts"]=""
    ["dirb"]=false
    ["dirb_opts"]=""
    ["nikto"]=false
    ["nikto_opts"]=""
    ["ffuf"]=false
    ["ffuf_opts"]=""
    ["html_comments"]=false
)

enable_autocomplete(){
    # Guide to enable autompletion to the tool

    cat << EOF
# Auto-completion for htbinit script
_htbinit_completion() {
    local current_word
    current_word="${COMP_WORDS[COMP_CWORD]}"

    # Define the available options
    local options="--help -H --add-tool --report --dry-run --dry -d --verbose -v --ip -i --host -h --https -s --http_port -p --scan_mode --user_ag -a --co
okie -c --extension -x --file_wordlist --subdomains --rustscan --nmap --dirb --nikto --ffuf --html-comments"

    # Allow completion for partial prefixes
    COMPREPLY=($(compgen -W "${options}" -- "${current_word}"))
}

# Register the completion function for htbinit
complete -F _htbinit_completion htbinit
EOF
}

is_zellij(){
    if [[ -z $ZELLIJ_SESSION_NAME ]]; then
        printf "\n\033[2m[\033[0m\033[31m!\033[0m\033[2m]\033[0m You will not be able to launch anything outside a zellij session\n"
        exit 1
    fi
}

active_debug(){
    if [[ $args["verbose"] == true ]]; then
        set -x
        echo "Verbose is ON"
    fi

    if [[ $args["dryrun"] == true ]]; then
        debug="echo "
        echo "Debugging is ON"
    fi
}

add_tool(){

    if [[ -z "$1" ]]; then
        newtool="foobar"
    else
        newtool="$1"
    fi

        cat << EOF
# Add your tool in the list (line 7 in the script):
tools=(rustscan dirb nikto ffuf nmap $newtool)

# Add in args array:
    ["$newtool"]=false
    ["${newtool}_opts"]=""

# Add in init_htb function:
            --$newtool)
                args["$newtool"]=true
                shift 1
                ;; 
            --${newtool}_opts)
                args["${newtool}_opts"]="\$2"
                shift 2
                ;;    

# Add a new function and its commandline arguments:
### ${newtool^^} ###
function $newtool(){

    # Extras parameters from the user
    if [[ -n \${args["${newtool}_opts"}"]} ]]; then
        user_opts=\${args["${newtool}_opts"]}
    fi

    cmd="$newtool -h \${args["http"]}://\${args["host"]} -p \${args["http_port"]} -o "./" \${user_opts}"
    echo "\$cmd"
}
EOF
}

make_report(){
    # Prepare a Markdown report
    printf "\nReport : Copy and paste this markdown to your favorite Markdown plateform\n"
    box_name=$(echo "${PWD##*/}")
    echo -e "
${box_name^}
- Ubuntu / Windows
- Port 
- 
- 
    "
    for file in $(ls ~/box/$box_name/*.txt ); do
        tool=$(basename "$file" | awk -F'[_]' '{print $1}')
        echo "### ${tool^}"
        echo "\`\`\`bash"
        cat $file
        echo "\`\`\`"
    done;
}


show_help() {
    echo -e "
░░░░░░░░███░░░░░░░░░░░░░░▒░░░░░░░░░░░░░░░
▒▒░▒░▒█▒░▒░░░▒░░░▒░▒░▒░▒░▒▒▓░▒░░▒░░░░░▒▒▒
░░░░░▒░░░░░░░░░░░░░░░░░▒▒░░░░░░░░░░░░░░░░
░░░░▒░░░░░░░░░░░░░░░░▓▒▒▒▒░░▓▓░░░░░░░░░░░
░▒▒█▓▒▒▒░▒▒▒░▒▒▒▒▒▒▓▓▓▒▓▓▓▓▒░█▒▒▒▒░▒░▒▒▒░
░░░█░░▒░░░▒▒░░░▒▓▓▒▒▒▒░▒▒▓▒░░░█░░░░░░░░░░
░░▒▓░░▒░░░░▒▒██▓▓▓█▒▒█▒▒███▓░░█░░░░░▒░░░░
▒▒▓▓░▒▒█▓▓▓▓▓▓▓▓█▓▓▓▓▓▓▓████▓▒█▒▒▒█▓▓▓▓▒▒
▒█▒▓░▒████▓▓▓▓▓▓▓▓█▓▓▓▓▓██▓█▓██▒▒▒▓▓░▒▒▒▒
░▒▒█░█▓███▓▒▓▓▓▒█▓█▓▓▓▓▓███████▓░▒▓▒▒▒▒▓░
▒▒▒█▒▓▓███▓▓▓▓▓▓▓▓▓▓▓▓▓▓██████▓▒▒▓▓▓▒▒▒▓▒
▒▒▒██▓▓████▒▓▒▓▒▓▓▓▓▓▓▓▓▓███▓▓▒▒▓▓▓▓▓▓▒▒▒
░▒▒▒█▓▓████▒▓█▓▒▓▓▓▒█▓▓▓▓███▓▒▒▓▓▓▓▓▓▒░░░
░▒░▒████████████▒███████████████████▒▒▒▒░
░▒░▒░▒▒█████▓▒▒▓▓▓▓▓▓██▓▓▒▓▓▓▓▓▓▓▓▓▒▒▒▒░░
░░░░▒▓░▒█▓▓▓▓▓▓▓▓▓█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒░▒▓▓░▒
░▒▒░░░▒▒▒▒▒█▒▒▒█▒███▒████████████▒▒▒▒▒▒▒░
▒▒░▒▒░▒░░▒▒▒▓▓▒▒▒▒▒█▓▒▒▓▓▓▓█▓▓▓▓▒░░▒▒▒▒░▒
▒▒▒▒░▒░▒░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒
░▒░▒░▒░▒░▒▒█████▓▓▓▓▓█▓▓▓▓▓█▓▒░░▒▒░░░░░▒░
████████████▓█▓▓▓▓▒████████▓██████████▓░░
████████████████▓████████████████████████                                                                                    
"
    cat << EOF
Usage: ${0##*/} [OPTIONS]

Example : ${0##*/} -v -i 10.10.10.10 -h domain.htb -p 8080 --dirb --ffuf

### Disclaimer : Be sure to have $(printf '\e]8;;http://zellij.dev/documentation/installation.html\a')zellij$(printf '\e]8;;\a') installed on your system. ###

Options:
  --help, -H                       Show this help message and exit
  --add-tool <name>                Show how to add a tool in the script
  --autocomplete                   Show how to add autocompletion
  --report                         Generate a Markdown report
     
  --dry-run, --dry, -d             Echo the commands instead of running them
  --verbose, -v                    Enable verbose/debug mode
  --ip, -i <IP_ADDRESS>            Target IP address
  --host, -h <HOSTNAME>            Target hostname (required)
  --https, -s                      Use HTTPS instead of HTTP
  --http_port, -p <PORT>           HTTP/HTTPS port to use (default: 80)
  --scan_mode <tcp|udp>            Choose scan mode (default: tcp)
  --user_ag, -a <AGENT>            Set a custom user-agent
  --cookie, -c <COOKIE>            Set a custom cookie
  --extension, -x <EXTENSION>      Set an extension for web scan
  --file_wordlist <FILE>           Set a wordlist for web scan
  --subdomains <FILE>              Set a wordlist for subdomains scan


Specify tools to run:
  --rustscan                  Run rustscan
  --nmap                      Run nmap
  --dirb                      Run dirb
  --nikto                     Run nikto
  --ffuf                      Run ffuf
  --html-comments             Run HTML comments parsing
EOF
}

init_htb(){
    if [ $# -eq 0 ]; then
        echo "No arguments supplied"
        show_help
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-H)
                show_help
                exit 0
                ;;
            --add-tool)
                add_tool "$2"
                exit 0
                ;;
            --dry-run|--dry|-d)
                args["dryrun"]=true
                shift 1
                ;;
            --verbose|-v)
                args["verbose"]=true
                shift 1
                ;;
            --ip|-i)
                args["ip"]="$2"
                shift 2
                ;;
            --host|-h)
                args["host"]="$2"
                shift 2
                ;;
            --https|-s)
                args["http"]="https"
                shift 1
                ;;
            --http_port|-p)
                args["http_port"]="$2"
                shift 2
                ;;
            --scan_mode)
                args["scan_mode"]="$2"
                shift 2
                ;;
            --extension|-x)
                args["extension"]="$2"
                shift 2
                ;;
            --file_wordlist|-fw)
                args["file_wordlist"]="$2"
                shift 2
                ;;
            --subdomains)
                args["subdomains"]="$2"
                shift 2
                ;;
            --user_ag|-a)
                args["user_ag"]="$2"
                shift 2
                ;;    
            --cookie|-c)
                args["cookie"]="$2"
                shift 2
                ;;
            --report)
               make_report
               exit 0
               ;;
            # Tools options
            --rustscan)
                args["rustscan"]=true
                shift 1
                ;;
            --rustscan_opts)
                args["dirb_opts"]="$2"
                shift 2
                ;;
            --nmap)
                args["nmap"]=true
                shift 1
                ;;
            --nmap_opts)
                args["dirb_opts"]="$2"
                shift 2
                ;;
            --dirb)
                args["dirb"]=true
                shift 1
                ;;
            --dirb_opts)
                args["dirb_opts"]="$2"
                shift 2
                ;;               
            --nikto)
                args["nikto"]=true
                shift 1
                ;;
            --nikto_opts)
                args["nikto_opts"]="$2"
                shift 2
                ;;   
            --ffuf)
                args["ffuf"]=true
                shift 1
                ;;         
            --ffuf_opts)
                args["ffuf_opts"]="$2"
                shift 2
                ;;   
            --html-comments)
                args["html_comments"]=true
                shift 1
                ;;                 
            *)
                echo "Unknown option: $1"
                echo "To show available options, use : init.sh --help/-H"
                exit 1
                ;;
        esac
    done
}

check_args(){

    if [[ -z ${args["host"]} ]]; then
        echo "Missing required argument: --host / -h"
        printf "\nUse \033[1m${args["ip"]}\033[0m instead ? (Press \"q\" to quit)\n"
        # Read a single character input
        read -s -n 1 input
        if [[ "$input" == "q" ]]; then
            printf "\n\033[2m[+]\033[0m \033[90m\033[3mProgram exit.\033[0m"
            exit 1
        fi
        args["host"]=${args["ip"]}
    fi

    if ! check_domain "${args["host"]}"; then
        printf "(!) Domain hostname is not a valid hostname, some tools will fail"
    fi

    if [[ -z ${args["ip"]} ]]; then
        echo "Missing required argument: --ip / -i"
        printf "\nUse \033[1m0.0.0.0\033[0m instead ? (Press \"q\" to quit)\n"
        # Read a single character input
        read -s -n 1 input
        if [[ "$input" == "q" ]]; then
            printf "\n\033[2m[+]\033[0m \033[90m\033[3mProgram exit.\033[0m"
            exit 1
        fi
        args["ip"]="0.0.0.0"
    fi

    if [[ "$1" != "_"* ]]; then
        "$@"
    else
        echo "Unknown subcommand: $1"
    fi
}


host_exists(){
    # Check if HOST already exist
    host_exists=$(cat "$etc_hosts" | grep "^${args["ip"]} ${args["host"]}$")

    if [[ ${args["ip"]} != ${args["host"]} ]] && [[ -n $host_exists ]]; then
        printf "\nEnter this line in your host file : \n\033[1m${args["ip"]} ${args["host"]}\033[0m\n\n"
        echo "${args["ip"]} ${args["host"]}" | xclip -selection clipboard

        if [[ $etc_hosts == *"Windows"* ]]; then
            # printf "Windows in etc_hosts"
            read -n 1 -p "Edit hosts file ? (n/N to skip) "$'\n' edit_host
            if [[ ! "$edit_host" =~ [nN] ]]; then
                powershell.exe Get-Command -ErrorAction Ignore -Type Application notepad++.exe
                powershell.exe Start-Process -Verb runas notepad++.exe $(wslpath -w "$etc_hosts")
                printf "\033[2m[+]\033[0m Next"
                read -p ""
            else
                printf "\n\033[2m[+]\033[0m Skipping...\n"
            fi
        fi
    else
    printf "\n\n\033[1m${args["ip"]} ${args["host"]}\033[0m \033[4malready exists\033[0m in your system resolver file\n\n"
    printf "\033[2m[+]\033[0m Found entry in $etc_hosts =>\033[1m $host_exists \033[0m\n\n"
    fi
}


check_ping(){
    # Check if the host can be called, if the VPN is up and running
    if [[ ${args["ip"]} == "0.0.0.0" ]]; then
        address=${args["host"]}
    else
        address=${args["ip"]}
    fi
    printf "\nTest a single ping to $address \n"
    ping -c 1 "$address" > /dev/null

    if [ $? -eq 0 ]; then
        printf "\033[2m[+]\033[0m $address is available\n"
    else
        printf "\033[2m[!]\033[0m $address is not available, check if OpenVPN is running\n"

        read -n 1 -p "Continue script ? (n/N)"$'\n' continue
        if [[ "$continue" =~ [nN] ]]; then
            printf "\n\033[2m[+]\033[0m \033[90m\033[3mProgram exit.\033[0m"
            exit 1
        fi
    fi
}

############## TOOLS ##############

### HTML COMMENTS ###
function html_comments(){
    # Parse every comments of the website
    # From dirb output, curl every web page
    found_pages="$1"

    # for page in $found_pages do
        # content=$(curl -XGET $page)
        # Catch content between HTML comments
        # pattern="class=\"([A-Za-z0-9_-]* )*$1( [A-Za-z0-9_-]*)*\""

        # result+=$(awk -v pat="$pattern" '
        # /<!-- main content -->/ {Y=1}
        # /<!-- end content -->/ {Y=0}
        # Y && $0 ~ pat {f[FILENAME] = f[FILENAME]" "FNR;}
        # END {for (k in f) printf "%s\tlines:%s\n", k,f[k];}
        # ' $content)
    # done

    # printf "\n\033[2m[+]\033[0m\n"
    # echo "$result"
    # cmd=""
    # echo "$cmd"
}



### FFUF ###
function ffuf(){

    if [[ -n ${args["subdomains"]} ]]; then
       wordlist=${args["subdomains"]}
    else
       wordlist="/usr/share/wordlists/subdomains.txt"
    fi

    # Manual options from user input
    if [[ -n ${args["ffuf_opts"]} ]]; then
        user_opts=${args["ffuf_opts"]}
    fi

    http="http"
    cmd="ffuf -w ${wordlist} -u ${args["http"]}://${args["host"]}:${args["http_port"]} -H 'Host: FUZZ.${args["host"]}' -ac -of html -o ffuf.html ${user_opts}"
    echo "$cmd"
}

### RUSTSCAN ####
function rustscan(){

    if [[ -z ${args["scan_mode"]} ]]; then
       scan_mode="--udp"
    fi

    # Manual options from user input
    if [[ -n ${args["rustscan_opts"]} ]]; then
        user_opts=${args["rustscan_opts"]}
    fi

    if [[ ${args["ip"]} == "0.0.0.0" ]]; then
        address=${args["host"]}
    else
        address=${args["ip"]}
    fi

    # allow current folder for Rustscan output file
    chmod 777 $(pwd)
    scan_cmd="docker run -v $(pwd):/output -it --rm --name rustscan rustscan/rustscan"
    cmd="${scan_cmd} -a ${address} -r 1-8000 -- -sV -sC -Pn -vvv -oN /output/rustscan.txt ${scan_mode} ${user_opts}"
    echo "$cmd"
}

### NMAP ####
function nmap(){

    # Manual options from user input
    if [[ -n ${args["nmap_opts"]} ]]; then
        user_opts=${args["nmap_opts"]}
    fi

    if [[ -n ${args["scan_mode"]} ]]; then
       scan_mode="--udp"
    fi
    cmd="nmap -Pn -sC -sV ${args["ip"]} -F -oN nmap.txt -vvv ${user_opts}"
    echo "$cmd"
}

### DIRB ####
function dirb(){

    if [[ -n ${args["user_ag"]} ]]; then
       user_agent="-a ${user_ag}"
    fi

    if [[ -n ${args["http_port"]} ]]; then
       port_opt="${args["http_port"]}"
    fi

    if [[ -n ${args["extension"]} ]]; then
        extension="-X ${args["extension"]}"
    fi

    if [[ -n ${args["cookie"]} ]]; then
       custom_cookie="-c ${cookie}"
    fi

    if [[ -n ${args["file_wordlist"]} ]]; then
       wordlist="${wordlist}"
    else
       wordlist="/usr/share/wordlists/SecLists/Discovery/Web-Content/common.txt,/usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt"
    fi

    # Manual options from user input
    if [[ -n ${args["dirb_opts"]} ]]; then
        user_opts=${args["dirb_opts"]}
    fi

    cmd="dirb ${args["http"]}://${args["host"]}:${port_opt}/ ${wordlist} -t -o dirb_output.txt ${user_agent} ${custom_cookie} ${extension} ${user_opts}"
    echo "$cmd"
}

### NIKTO ###
function nikto(){

    if [[ -n ${args["http_port"]} ]]; then
       port_opt="${args["http_port"]}"
    fi

    # Manual options from user input
    if [[ -n ${args["nikto_opts"]} ]]; then
        user_opts=${args["nikto_opts"]}
    fi

    cmd="nikto -h ${args["http"]}://${args["host"]}:$port_opt -Format txt -output '.' ${user_opts}"
    echo "$cmd"
}

### Confirm command line ###
confirm(){
   # $1 = commandline string
   # $2 zellij pane-name

   cmdline="$debug $1"
   printf "\033[2m[+]\033[0m\033[44;1m$cmdline\033[0m\n\n"
   read -n 1 -t 7 -p "Launch pane ? (n/N to skip) "$'\n' launch
   printf "\n\n"
   if [[ ! "$launch" =~ [nN] ]]; then
      zellij ac new-pane --name "$2" --start-suspended -- bash -c "$cmdline"
   fi
}


## Validate domain using regex ##
check_domain(){
    domain=$1

    regex='^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.[A-Za-z]{2,}$'
    if [[ $domain =~ $regex ]]; then
        return 0
    else
        # Not a valid hostname
        return 1
    fi
}

launch_tools(){

    for tool in "$@"; do
        printf "\033[33;1m${tool^^}\033[0m\n"

        # Special case: FFUF needs host
        if [[ $tool == "ffuf" && "${args["host"]}" =~  ^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$ ]]; then
            echo "Skipping FFuF (no domain to resolve)"
            continue
        fi
        if declare -f "$tool" > /dev/null; then
            confirm "$($tool)" "$tool"
        else
            echo "Function '$tool' not defined!"
        fi
    done
}

### Main function ###
main(){
    check_args
    active_debug
    host_exists
    check_ping

    if [[ -z $(ps aux | grep docker | grep -v "grep")  ]]; then
        printf "\n\033[31;47;4;1m/!\ Don't forget to start docker service\033[0m \033[31;47;9mor consequences\033[0m\n"
        read -t 10 -p "Continue when docker service is running (or proceed and skip manually)"$'\n'
    fi

    # If the user chooses to enable specific tools in option
    enabled_tools=()

    for tool in "${tools[@]}"; do
        if [[ ${args[$tool]} == true ]]; then
            explicit_selection=true
            enabled_tools+=("$tool")
        fi
    done

    if [[ $explicit_selection == false ]]; then
        printf "\n\033[2m[i]\033[0m No tools specified, running all tools by default\n\n"
        launch_tools "${tools[@]}"
    else
        launch_tools "${enabled_tools[@]}"
    fi
}

is_zellij
# Parse every options
init_htb "$@"
main

# Disable debugging even off
set +x