# htbinit
Bash script using Zellij (terminal multiplexer) to faciliate the start of HackTheBox and other cybersecurity labs.

Not a crazy ctf nor htb player. I just needed a script to start boxes without losing time on my note taking in Markdown, updating the host file, or with the amount of tools needed with foothold / web steps.

Updating it according to my need, using it with wsl2

### 🍌🐒 TODO :
- [ ] Make the script better
- [ ] Stop using bash
- [ ] Remove Todos from the script
- [ ] Use default note app when Windows
- [ ] Add severals wordlists to Dirb
- [ ] Add html comments scraping tool
- [ ] Improve Zellij new-pane selection
- [ ] Improve the Markdown report
- [ ] Make an installation script to add completion in .bashrc (?)

### Usage

```bash
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

Usage: htbinit [OPTIONS]

Example : htbinit -v -i 10.10.10.10 -h domain.htb -p 8080 --dirb --ffuf

### Disclaimer : Be sure to have zellij installed on your system. ###

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
  --html-comments             Run HTML comments parsin
```

### Install
```bash
sudo chmod +x htbinit.sh
sudo ln -sf htbinit.sh /usr/bin/htbinit
```

### 😼 Links

[RootMe 💀](http://catleidoscope.sergethew.com/) - [HackTheBox 🟩](https://hackertyper.com/)
