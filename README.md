Use Google Takeout to download your classic Hangouts conversations. 

Here are two scripts, one for Mac/Linux using Python3 and another for Windows Powershell.

# Windows Powershell script run from cmdline:
Use File Explorer and browse to the location where you stored the Hangouts.ps1 file (Example: C:\Temp)

    Then use Menu: File -> Open Windows PowerShell

Once window opens and you get the prompt (Example: PS C:\Temp)

Make sure your json file and ps1 files are both listed
PS C:\Temp> dir

    Directory: C:\Temp

Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---          6/4/2020   1:56 PM  110143048 Hangouts.json
-a---          6/8/2020   2:59 PM      16568 Hangouts.ps1

Run it:
PS C:\Temp> .\Hangouts.ps1 Hangouts.json > Hangouts.txt
   tip: to see what it is doing, use the following command: .\Hangouts.ps1 Hangouts.json | Tee-Object -file Hangouts.txt
        this can add some time to the processing, 10 minutes instead of 4 minutes for my json file
Press ENTER to execute the script. (can take a while. Mine took 4 minutes)

Once done:
PS C:\Temp> dir


    Directory: C:\Temp


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---          6/4/2020   1:56 PM  110143048 Hangouts.json
-a---          6/8/2020   2:59 PM      16568 Hangouts.ps1
-a---          6/8/2020   3:04 PM   36965356 Hangouts.txt

# Python3
Make sure Python3 is in your PATH env
Example using /tmp as location where you stored the hangouts_json.py file
Copy your downloaded Takeout files to here and uncompress to Takeout/Hangouts/

cd /tmp
cp ~/Downloads/Takeout.zip /tmp
unzip Takeout.zip
Run it (defaults parsed file to current folder and Hangouts.txt as name)
python3 hangouts_json.py -i Takeout/Hangouts/Hangouts.json
 OR specify parsed file name location:
python3 hangouts_json.py -i Takeout/Hangouts/Hangouts.json -o Takeout/Hangouts/Hangouts.txt

Loading took 2.485398769378662 seconds.
Parsing took 1.1554899215698242 seconds.
Your messages should now all be copied to Hangouts.txt


# Example output

Conversations
*These are your hangouts
*Each conversation has a unique conversation id, that can be used to search the raw json file for the specific conversation
___________________________________________________________________________________________________________________________
 
Conversation ID    - Vxgie3Js-JzZxrTypgv4BaXYZQ
Conversation Type  - you and a group of people (2 or more participants)
Conversation State - ARCHIVED
Hangouts Conversation
History is ON
Using Data/WiFi
Participant Name  - John Doe  - Hangouts user
Participant Name  - Jane Doe  - Hangouts user
  Messages
   Conversations can contain one or many message events
   A message event can be for starting a Hangout, adding a user or for each message sent/received 
   Each message event has a unique message id that can be used to search the raw json file for the specific event
 
    Message ID       : 9-A0X7-1Rft3-L0ZCIOqv5
    Message Date Time: Fri, 24 May 2013 12:01:02 -0600
    Participant      : Jane Doe
     STARTING a Hangout
 
    Message ID       : 9-A0X7-1Rft3-L1L4Q26j7
    Message Date Time: Fri, 24 May 2013 12:07:51 -0600
    Participant      : John Doe
     ADD Participant : John Doe
 
    Message ID       : 9-A0X7-1Rft3-L1oo9UTAm
    Message Date Time: Fri, 24 May 2013 12:12:02 -0600
    Participant      : John Doe
     ENDING a Hangout
     Duration (seconds) : 660
 
   Conversation ID -  Vxgie3Js-JzZxrTypgv4BaXYZQ  had  3  message events
 
Conversation ID    - Vxgie7Ds-AzTxrZypgv0AaQZXY
Conversation Type  - you and one other person (2 participants)
Conversation State - ARCHIVED
Hangouts Conversation
History is ON
Using Data/WiFi
Participant Name  - John Doe  - Hangouts user
Participant Name  - Jane Doe  - Hangouts user
  Messages
   Conversations can contain one or many message events
   A message event can be for starting a Hangout, adding a user or for each message sent/received 
   Each message event has a unique message id that can be used to search the raw json file for the specific event
 
    Message ID       : 9-A0X7-5Tvc2-L0gyi6iaL
    Message Date Time: Mon, 19 May 2014 13:08:43 -0600
    Participant      : Jane Doe
     MESSAGE " hi! "
 
    Message ID       : 9-A0X7-5Tvc2-L0lmMzOJp
    Message Date Time: Mon, 19 May 2014 13:09:22 -0600
    Participant      : John Doe
     MESSAGE " hi "
  
    Message ID       : 9-A0X7-5Tvc2-L0v2ehJam
    Message Date Time: Mon, 19 May 2014 13:10:38 -0600
    Participant      : John Doe
     MESSAGE " what's up? "
 
    Message ID       : 9-A0X7-5Tvc2-L0viKiayi
    Message Date Time: Mon, 19 May 2014 13:10:44 -0600
    Participant      : Jane Doe
     MESSAGE " please send me that email adress again "
  
    Message ID       : 9-A0X7-5Tvc2-L11YKJZ8n
    Message Date Time: Mon, 19 May 2014 13:11:40 -0600
    Participant      : John Doe
     MESSAGE " Here you go:  "
     MESSAGE " xxxx.xx@xxxxx.com "
     MESSAGE "  <mailto: "
     MESSAGE " xxxx.xx@xxxxx.com "
     MESSAGE " > "
  
    Message ID       : 9-A0X7-5Tvc2-L17FBy_Oe
    Message Date Time: Mon, 19 May 2014 13:12:26 -0600
    Participant      : Jane Doe
     MESSAGE " thanks, but what are the x's for? "
 
    Message ID       : 9-A0X7-5Tvc2-L1E62e4eY
    Message Date Time: Mon, 19 May 2014 13:13:22 -0600
    Participant      : John Doe
     MESSAGE " LOL "
 
    Message ID       : 9-A0X7-5Tvc2-L1Fgamx_8
    Message Date Time: Mon, 19 May 2014 13:13:35 -0600
    Participant      : John Doe
     MESSAGE " i just sent you a dummy email address "
 
    Message ID       : 9-A0X7-5Tvc2-L1Hdur1Nm
    Message Date Time: Mon, 19 May 2014 13:13:52 -0600
    Participant      : Jane Doe
     MESSAGE " ok "
 
   Conversation ID -  Vxgie7Ds-AzTxrZypgv0AaQZXY  had  9  message events
 

