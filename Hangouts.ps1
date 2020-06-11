#Powershell script run from cmdline:
#Browse to the location you stored the Hangouts.ps1 file in File Explorer (C:\Temp)
#Menu: File -> Open Windows PowerShell [-> Open Windows PowerShell
#Once window opens and you get the prompt (PS)
#  cd to the directory that has the Takeout files
#  Type (part of) the name of the script.
#   Press TAB to autocomplete then name. Note: Do this even when you typed the name in full. 
#   Include the json filepath
#   Iclude then output filepath
#PS C:\WINDOWS\system32> cd C:\Temp
#Make sure your json file and ps1 files are both listed
#PS C:\Temp> dir
#
#
#    Directory: C:\Temp
#
#
#Mode                LastWriteTime     Length Name                                                                                                  
#----                -------------     ------ ----                                                                                                  
#-a---          6/4/2020   1:56 PM  110143048 Hangouts.json                                                                                         
#-a---          6/8/2020   2:59 PM      16568 Hangouts.ps1                                                                                          
#
#PS C:\Temp> .\Hangouts.ps1 Hangouts.json > Hangouts.txt
#   tip: to see what it is doing, use the following command: .\Hangouts.ps1 Hangouts.json | Tee-Object -file Hangouts.txt
#        this can add some time to the processing, 10 minutes instead of 4 minutes for my json file
#Press ENTER to execute the script. (can take a while. Mine took 4 minutes)
# once done:
#PS C:\Temp> dir
#
#
#    Directory: C:\Temp
#
#
#Mode                LastWriteTime     Length Name                                                                                                  
#----                -------------     ------ ----                                                                                                  
#-a---          6/4/2020   1:56 PM  110143048 Hangouts.json                                                                                         
#-a---          6/8/2020   2:59 PM      16568 Hangouts.ps1                                                                                          
#-a---          6/8/2020   3:04 PM   36965356 Hangouts.txt
#

param(
        [Parameter(Position=0,mandatory)]
        [string] $infile = 'Hangouts.json'
) 

if(-not($infile)) { 
        Throw “You must supply the json filename and path. Example: -infile C:\Temp\Hangouts.json” 
    } else {
        $file = $infile
        Write-Output('Processing file',$file)
}

$StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$StopWatch.Start()
#huge file so have to change maxlength, cannot read and convert in one line
$json = Get-Content $file -Raw
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
$result = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=167108864}).DeserializeObject($json)
$StopWatch.Stop()
$loadtime = $StopWatch.Elapsed.ToString()
Write-Output('Reading the file took ' + $loadtime + ' to run.')

$StopWatch.Start()
$a=0  #conversation counter
Write-Output('Conversations')
Write-Output('*These are your hangouts')
Write-Output('*Each conversation has a unique conversation id, that can be used to search the raw json file for the specific conversation')
Write-Output('___________________________________________________________________________________________________________________________')
Write-Output(' ')
#loop through each conversation
foreach ($i in $result.conversations) { 
    Write-Output('Conversation ID    - ' + $i.conversation.conversation_id.id)
    if  ($i.conversation.conversation.name) {
        Write-Output('Conversation Name  - "' + $i.conversation.conversation.name + '"') 
        $conversationname = $i.conversation.conversation.name
    } else {
        $conversationname = $i.conversation.conversation_id.id
    }

    if ($i.conversation.conversation.type -eq  'STICKY_ONE_TO_ONE'){
        Write-Output('Conversation Type  - you and one other person (2 participants)')
    } else {
        Write-Output('Conversation Type  - you and a group of people (2 or more participants)')
      }
    
    if ($i.conversation.conversation.self_conversation_state.view -eq  'INBOX_VIEW'){
        Write-Output('Conversation State - Active')
    } else {
        Write-Output('Conversation State - ARCHIVED')
    }   
    
    $bb = $i.conversation.conversation.self_conversation_state.delivery_medium_option.values.medium_type 
    if ($bb -eq 'BABEL_MEDIUM'){
        Write-Output('Hangouts Conversation')
    } elseif ($bb -eq 'GOOGLE_VOICE_MEDIUM'){
        Write-Output('Hangouts using Google Voice')
    } else {
        Write-Output('Hangouts using Other Service')
    }     
    
    if ($i.conversation.conversation.otr_toggle -eq  'ENABLED'){
        Write-Output('History is ON')
    } else {
        Write-Output('History is OFF')
    }
    
    $cc = $i.conversation.conversation.network_type
    if ($cc -eq  'BABEL') {
        Write-Output('Using Data/WiFi')
    } else {
        Write-Output('Using GV/GF/Carrier')
    }
    
    $participantDict = @()
    if ($i.conversation.conversation.participant_data) {
        foreach ($x in $i.conversation.conversation.participant_data) {
                $participantid = $x.id.gaia_id
                if ($x.fallback_name) {
                    $participantname = $x.fallback_name
                } else {
                    $participantname = $participantid
                }
                $participantDict += ,@($participantid,$participantname)
                if ($i.conversation.conversation.participant_data) {
                    $participanttype = $x.participant_type
                    if ($participanttype -eq  'OFF_NETWORK_PHONE') {
                        $participantnum = $x.phone_number.e164
                        Write-Output('Participant Name  -' + $participantname + ' - GV/GF/Carrier user - Phone :' + $participantnum)
                    } else {
                        Write-Output('Participant Name  -' + $participantname + ' - Hangouts user')
                    }
                } else {
                Write-Output('Participant Name  -' + $participantname)
                }
        }
     }
    #loop through each message event 
    $b=0 #event counter per conversation
    Write-Output('  Messages')
    Write-Output('   Conversations can contain one or many message events')
    Write-Output('   A message event can be for starting a Hangout, adding a user or for each message sent/received ')
    Write-Output('   Each message event has a unique message id that can be used to search the raw json file for the specific event')
    Write-Output(' ')
    foreach ($y in $i.events) {
        Write-Output('    Message ID       : ' + $y.event_id)
        [double]$epoch_time = $y.timestamp
        $myDateTime = [DateTimeOffset]::FromUnixTimeMilliseconds($epoch_time/1000).LocalDateTime
        Write-Output('    Message Date Time: ' + $myDateTime.DateTime)
        $participantid = $y.sender_id.gaia_id
        foreach ($z in $participantDict) {
            If ($z -contains $participantid) {
                $participantname = $z[1]
                break
            } else { 
                $participantname = $participantid
            }
        }
        Write-Output('    Participant        ' + $participantname)
        $deliverymedium = $y.delivery_medium.medium_type
        $eventtype = $y.event_type
        if ($eventtype -eq  'HANGOUT_EVENT'){
            if ($y.hangout_event.event_type -eq  'START_HANGOUT')  {
                Write-Output('     STARTING a Hangout')
                if  ($y.conversation.conversation.name) {
                    Write-Output('Conversation Name  - "' + $y.conversation.conversation.name + '"') 
                }
                if ($y.hangout_event.media_type -eq  'AUDIO_ONLY')  {
                        Write-Output('     Phone Call')
                } else {
                        Write-Output('     Video Call')
                       }
            } else {
                Write-Output('     ENDING a Hangout')
                if ($y.hangout_event.media_type -eq  'AUDIO_ONLY')  {
                        Write-Output('     Phone Call')
                } else {
                        Write-Output('     Video Call')
                       }
                
                if ($y.hangout_event.hangout_duration_secs) {
                   Write-Output('     Duration in seconds ' + $y.hangout_event.hangout_duration_secs)
                   }
                }
        } elseif ($eventtype -eq  'ADD_USER'){
            $participantid = $y.membership_change.participant_id.gaia_id
            foreach ($z in $participantDict) {
                If ($z -contains $participantid) {
                    $participantname = $z[1]
                    break
                } else { 
                    $participantname = $participantid
                }
            }
            Write-Output('     ADD Participant    ' + $participantname)
        } elseif ($eventtype -eq  'REGULAR_CHAT_MESSAGE') {
            if ($y.chat_message.message_content.segment) {
                $chattext = ''
                foreach ($x in $y.chat_message.message_content.segment) {
                    $chattype = $x.type
                    if ($chattype -eq  'LINE_BREAK'){
                        Write-Output('     MESSAGE "' + $chattext + '"')
                        $chattext = ''
                    } elseif ($chattype -eq  'LINK'){
                        Write-Output('     MESSAGE "' + $chattext + '"')
                        $chattext = $x.text
                        Write-Output('     MESSAGE "' + $chattext + '"')
                        $chattext =  ''
                    } else {
                        $chattext =  $chattext + $x.text
                    }
                }
                Write-Output('     MESSAGE "' + $chattext + '"')
            }
            if ($y.chat_message.message_content.attachment) {
                foreach ($x in $y.chat_message.message_content.attachment) {
                        $aid = $x.id
                        $atype = $x.embed_item.type
                        if ($atype -eq 'PLUS_PHOTO'){
                            $mediatype = $x.embed_item.plus_photo.media_type
                            $mediaurl = $x.embed_item.plus_photo.thumbnail.url
                            $medianame = Split-Path $x.embed_item.plus_photo.url -leaf
                            Write-Output('      ' + $mediatype + ' - NAME - ' + $medianame)
                            Write-Output('      ' + $mediatype + '   Look in the same takeout directory as your "Hangouts.json" file, for the actual file.')
                            Write-Output('      ' + $mediatype + ' - URL - ' + $mediaurl)
                            Write-Output('      ' + $mediatype + '   This URL should get you to the file online to download')
                        } elseif ($atype -eq 'PLACE_V2'){
                            $mediaurl = $x.embed_item.place_v2.url
                            $medianame = $x.embed_item.place_v2.name
                            $mediaaddress = ''
                            if ($x.embed_item.place_v2.address.postal_address_v2.street_address) {
                                $mediaaddress = $x.embed_item.place_v2.address.postal_address_v2.street_address
                            } elseif ($x.embed_item.place_v2.address.postal_address_v2.name) {
                                $mediaaddress = $x.embed_item.place_v2.address.postal_address_v2.name
                                $mediaaddress = $mediaaddress + '`n' + $x.embed_item.place_v2.address.postal_address_v2.address_country
                                $mediaaddress = $mediaaddress + '`n' + $x.embed_item.place_v2.address.postal_address_v2.address_locality
                                $mediaaddress = $mediaaddress + '`n' + $x.embed_item.place_v2.address.postal_address_v2.address_region
                                $mediaaddress = $mediaaddress + '`n' + $x.embed_item.place_v2.address.postal_address_v2.postal_code
                            } else {
                                   $mediaaddress = 'No address listed'
                            }
                            Write-Output('        MAP - A map location was shared with you.')
                            Write-Output('        MAP - URL - ' + $mediaurl)
                            Write-Output('        MAP - NAME - ' + $medianame + 'Pinned name or map coordinates')
                            Write-Output('        MAP - ADDRESS - ' + $mediaaddress)
                        } else {
                            Write-Output('     UNKNOWN - ' + $mediatype + ' - ' + $atype + ' ** Will have to parse thee JSON file for this type **')
                            }
                }
            }
        } elseif ($eventtype -eq  'SMS') {
            if ($y.chat_message.message_content.segment) {
                $chattext = ''
                foreach ($x in $y.chat_message.message_content.segment) {
                    $chattype = $x.type
                    if ($chattype -eq  'LINE_BREAK'){
                        Write-Output('         SMS "' + $chattext + '"')
                        $chattext = ''
                    } else {
                        $chattext =  $chattext + $x.text
                    }
                }
                Write-Output('         SMS "' + $chattext + '"')
            }
            if ($y.chat_message.message_content.attachment) {
                foreach ($x in $y.chat_message.message_content.attachment) {
                        $aid = $x.id
                        $atype = $x.embed_item.type
                        if ($atype -eq 'PLUS_PHOTO'){
                            $mediatype = $x.embed_item.plus_photo.media_type
                            $originalurl = $x.embed_item.plus_photo.original_content_url
                            Write-Output('         SMS' + $mediatype + ' - URL - ' + $originalurl)
                            if ($mediatype -eq  'VIDEO'){
                                downloadurl = $x.embed_item.plus_photo.download_url
                                Write-Output('         SMS' + $mediatype + ' - DOWNLOAD - ' + $downloadurl)
                            } else {
                                Write-Output('')
                               }
                        } else {
                            $duration = $x.embed_item.plus_audio_v2.duration
                            $originalurl = $x.embed_item.plus_audio_v2.url
                            $embedurl = $x.embed_item.plus_audio_v2.embed_url
                            Write-Output('         SMS VOICEMAIL  - duration - ' + $duration)
                            if ($deliverymedium -eq  'GOOGLE_VOICE_MEDIUM'){
                                Write-Output('         SMS VOICEMAIL - Check Google Voice Takeout for the mp3 file - ')
                            } else {
                                Write-Output('         SMS VOICEMAIL - Check your phone service for the mp3 file - ')
                            }
                        }
                }
            }
       } elseif ($eventtype -eq  'VOICEMAIL'){
            if ($y.chat_message.message_content.segment) {
                $chattext = ''
                foreach ($x in $y.chat_message.message_content.segment) {
                    $chattype = $x.type
                    if ($chattype -eq  'LINE_BREAK'){
                        Write-Output('     VOICEMAIL Transcript - "' + $chattext + '"')
                        chattext = ''
                    } else {
                        $chattext =  $chattext + $x.text
                    }
                }
                Write-Output('     VOICEMAIL "' + $chattext + '"')
            }
            if ($y.chat_message.message_content.attachment) {
                foreach ($x in $y.chat_message.message_content.attachment) {
                    $aid = $x.id
                    $atype = $x.embed_item.type
                    $duration = $x.embed_item.plus_audio_v2.duration
                    Write-Output('     VOICEMAIL - duration - ' + $duration)
                    if ($deliverymedium -eq  'GOOGLE_VOICE_MEDIUM'){
                        Write-Output('     VOICEMAIL - Check Google Voice Takeout for the mp3 file - ')
                    } else {
                        Write-Output('     VOICEMAIL - Check your phone service for the mp3 file - ')
                    }
                }
            }
        } else {
           Write-Output('    Event Type Unknown')
        }
    #
    $b += 1
    Write-Output(' ')
    } # EO Events
    Write-Output('   Conversation ID - ' + $conversationname + ' had ' + $b + ' message events')
    $a += 1
    Write-Output(' ')
} #EO Conversations
Write-Output('Total Conversations: ' + $a)
$StopWatch.Stop()
$parsetime = $StopWatch.Elapsed.ToString()
Write-Output('Parsing the file took ' + $parsetime + ' to run.')

# Total Conversations: 251
# Parsing the file took 00:08:48.0387359 to run. 
 