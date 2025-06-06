# RMigratin requirements checkup in Python

# Check current OS (Windows vs. Linux vs. Mac)

import platform
import os
import sys

print("You are currently running rAIdline on the following platform", print(os.name), ",", print(sys.platform))

if os.name == 'windows':
    print("It is not currently possible to run rAIdline on this OS, please try and use Linux or Mac instead")


#
#Env Setup
#



# At then end of the setup, redirect to the correct setup bash script (or launch it directly for all I know)
if os.name == mac
    print("You should use now the following setup script : mac_setup_raidline_response.sh")
else:
    print("You should use now the following setup script : linux_setup_raidline_response.sh")
