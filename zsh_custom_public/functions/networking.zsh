# ii: Display comprehensive host and network information.
# This function gathers system details including hostname, kernel info,
# logged-in users, current date, uptime, memory usage, and IP addresses.
# It relies on a 'my_ip' function/command to populate MY_IP and MY_ISP variables.
function ii()
{
  RED='\e[1;31m'
  echo -e "\nYou are logged on ${RED}$HOST"
  echo -e "\nAdditionnal information:$NC " ; uname -a
  echo -e "\n${RED}Users logged on:$NC " ; w -h
  echo -e "\n${RED}Current date :$NC " ; date
  echo -e "\n${RED}Machine stats :$NC " ; uptime
  echo -e "\n${RED}Memory stats :$NC " ; free
  my_ip 2>&- ;
  echo -e "\n${RED}Local IP Address :$NC" ; echo ${MY_IP:-"Not connected"}
  echo -e "\n${RED}ISP Address :$NC" ; echo ${MY_ISP:-"Not connected"}
  echo
}
