#Python3 JSON parser
#cd /tmp
#python3 hangouts_json.py -i Takeout/Hangouts/Hangouts.json
# OR
#python3 hangouts_json.py -i Takeout/Hangouts/Hangouts.json -o Takeout/Hangouts/Hangouts.txt

#Loading took 2.485398769378662 seconds.
#Parsing took 1.1554899215698242 seconds.
#Your messages should now all be copied to Hangouts.txt
#
# conversations are hangouts
# each conversation has many message events. An event is one message sent or received
#
import time
import sys #used for debugging ouput
import os #used for filename parsing
import json
import argparse

parser = argparse.ArgumentParser(description='Parses your Hangouts.json file. Make sure this is run from the same path as the input file')
parser.add_argument('-i','--infile', default='Hangouts.json', required=False, help='INPUT Hangouts.json file. examples: /tmp/Hangouts.json or C:\Temp\Hangouts.json')
parser.add_argument('-o', '--outfile', default='Hangouts.txt', required=False, help='OUTPUT Hangouts.txt file. examples: /tmp/Hangouts.txt or C:\Temp\Hangouts.txt')
args = parser.parse_args()
jsonfile = args.infile
textfile = args.outfile

loadtime = time.time()
with open(jsonfile, 'r') as f:
    jsondata = json.load(f)

print('Loading took', time.time()-loadtime, 'seconds.')

parsestart = time.time()
#redirect to output file
sys.stdout = open(textfile, 'w')

#process all of your conversations
a=0  #conversation counter
print("Conversations")
print("*These are your hangouts")
print("*Each conversation has a unique conversation id, that can be used to search the raw json file for the specific conversation")
print("___________________________________________________________________________________________________________________________")
print(" ")
for x in jsondata["conversations"]:
    b=0 #event counter per conversation
    print("Conversation ID    -", x['conversation']['conversation_id']['id'])
    try:
        print("Conversation Name",'"{}"'.format(x['conversation']['conversation']['name']))
    except KeyError:
        pass
    if x['conversation']['conversation']['type'] == "STICKY_ONE_TO_ONE":
        print("Conversation Type  - you and one other person (2 participants)")
    else:
        print("Conversation Type  - you and a group of people (2 or more participants)")
    aa = x['conversation']['conversation']['self_conversation_state']['view']
    if aa[0] == "INBOX_VIEW":
        print("Conversation State - Active")
    else:
        print("Conversation State - ARCHIVED")
    bb = x['conversation']['conversation']['self_conversation_state']['delivery_medium_option'][0]['delivery_medium']['medium_type']
    if (bb == "BABEL_MEDIUM"):
        print("Hangouts Conversation")
    elif (bb == "GOOGLE_VOICE_MEDIUM"):
        print("Hangouts using Google Voice")
    else:
        print("Hangouts using Other Service")
    if x['conversation']['conversation']['otr_toggle'] == "ENABLED":
        print("History is ON")
    else:
        print("History is OFF")
    cc = x['conversation']['conversation']['network_type']
    if cc[0] == "BABEL":
        print("Using Data/WiFi")
    else:
        print("Using GV/GF/Carrier")
    participantDict = {}
    for i in range(0, len(x['conversation']['conversation']['participant_data'])):
        participantid = x['conversation']['conversation']['participant_data'][i]['id']['gaia_id']
        if 'fallback_name' in x['conversation']['conversation']['participant_data'][i]:
            participantname = x['conversation']['conversation']['participant_data'][i]['fallback_name']
        else:
            participantname = participantid
        participantDict[participantid] = participantname
        if 'participant_type' in x['conversation']['conversation']['participant_data'][i]:
            participanttype = x['conversation']['conversation']['participant_data'][i]['participant_type']
            if participanttype == "OFF_NETWORK_PHONE":
                participantnum = x['conversation']['conversation']['participant_data'][i]['phone_number']['e164']
                print("Participant Name  -", participantname," - GV/GF/Carrier user - Phone :", participantnum)
            else:
                print("Participant Name  -", participantname," - Hangouts user")
        else:
            print("Participant Name  -", participantname)
    # process the messages in the conversation
    print('  Messages')
    print("   Conversations can contain one or many message events")
    print("   A message event can be for starting a Hangout, adding a user or for each message sent/received ")
    print("   Each message event has a unique message id that can be used to search the raw json file for the specific event")
    print(" ")
    for y in x['events']:
        print("    Message ID       :", y['event_id'])
        etime = int(y['timestamp'])
        ttime = time.strftime("%a, %d %b %Y %H:%M:%S -0600", time.localtime(etime/1000000))
        print("    Message Date Time:", ttime)
        participantid = y['sender_id']['gaia_id']
        if participantid in participantDict:
            participantname = participantDict.get(participantid)
        else:
            participantname = participantid
        print("    Participant      :" ,participantname)
        deliverymedium = y['delivery_medium']['medium_type']
        eventtype = y['event_type']
        if (eventtype == "HANGOUT_EVENT"):
            if y['hangout_event']['event_type'] == "START_HANGOUT":
                print("     STARTING a Hangout")
                try:
                    if y['hangout_event']['media_type'] == "AUDIO_ONLY":
                        print("     Phone Call")
                    else:
                        print("     Video Call")
                except KeyError:
                    pass
            else:
                print("     ENDING a Hangout")
                try:
                    if y['hangout_event']['media_type'] == "AUDIO_ONLY":
                        print("     Phone Call")
                    else:
                        print("     Video Call")
                except KeyError:
                    pass
                try:
                    print("     Duration (seconds) :",y['hangout_event']['hangout_duration_secs'])
                except KeyError:
                    pass
        elif (eventtype == "ADD_USER"):
            try:
                participantid = y['membership_change']['participant_id'][0]['gaia_id']
                if participantid in participantDict:
                    participantname = participantDict.get(participantid)
                else:
                    participantname = participantid
                print("     ADD Participant:" ,participantname)
            except KeyError:
                pass
        elif (eventtype == "REGULAR_CHAT_MESSAGE"):
            try:
                chattext = ""
                for i in range(0, len(y['chat_message']['message_content']['segment'])):
                    chattype = y['chat_message']['message_content']['segment'][i]['type']
                    if (chattype == "LINE_BREAK"):
                        print("     MESSAGE", "\"", chattext, "\"")
                        chattext = ""
                    elif (chattype == "LINK"):
                        print("     MESSAGE", "\"", chattext, "\"")
                        chattext = y['chat_message']['message_content']['segment'][i]['text']
                        print("     MESSAGE", "\"", chattext, "\"")
                        chattext =  ""
                    else:
                        chattext =  chattext + y['chat_message']['message_content']['segment'][i]['text']
                print("     MESSAGE", "\"", chattext, "\"")
            except KeyError:
                pass
            try:
                for j in range(0, len(y['chat_message']['message_content']['attachment'])):
                    try:
                        aid = y['chat_message']['message_content']['attachment'][j]['id']
                        atype = y['chat_message']['message_content']['attachment'][j]['embed_item']['type']
                        if (atype[0] == "PLUS_PHOTO"):
                            mediatype = y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_photo']['media_type']
                            mediaurl = y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_photo']['thumbnail']['url']
                            medianame = os.path.basename(y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_photo']['url'])
                            print("      ",mediatype, " - NAME - ", medianame)
                            print("      ",mediatype, "   Check your downloaded Takeout folder for the actual file. Look in the same directory as your \"Hangouts.json\" file. Hopefully this info can help find it")
                            print("      ",mediatype, " - URL - ", mediaurl)
                            print("      ",mediatype, "   This URL should get you to the file online to download")
                        elif (atype[0] == "PLACE_V2"):
                            mediaurl = y['chat_message']['message_content']['attachment'][j]['embed_item']['place_v2']['url']
                            medianame = y['chat_message']['message_content']['attachment'][j]['embed_item']['place_v2']['name']
                            mediaaddress = ""
                            try:
                                mediaaddress = y['chat_message']['message_content']['attachment'][j]['embed_item']['place_v2']['address']['postal_address_v2']['street_address']
                            except KeyError:
                                pass
                            try:
                                mediaaddress = y['chat_message']['message_content']['attachment'][j]['embed_item']['place_v2']['address']['postal_address_v2']['name']
                                mediaaddress = mediaaddress + "\n" + y['chat_message']['message_content']['attachment'][j]['embed_item']['place_v2']['address']['postal_address_v2']['address_country']
                                mediaaddress = mediaaddress + "\n" + y['chat_message']['message_content']['attachment'][j]['embed_item']['place_v2']['address']['postal_address_v2']['address_locality']
                                mediaaddress = mediaaddress + "\n" + y['chat_message']['message_content']['attachment'][j]['embed_item']['place_v2']['address']['postal_address_v2']['address_region']
                                mediaaddress = mediaaddress + "\n" + y['chat_message']['message_content']['attachment'][j]['embed_item']['place_v2']['address']['postal_address_v2']['postal_code']
                            except KeyError:
                                pass
                            print("        MAP - A map location was shared with you.")
                            print("        MAP - URL - ", mediaurl)
                            print("        MAP - NAME - ", medianame, "Pinned name or map coordinates")
                            print("        MAP - ADDRESS - ", mediaaddress)
                        else:
                            print("     UNKNOWN", " - mediatype - ", atype," ** Will have to parse thee JSON file for this type **")
                    except KeyError:
                        pass
            except KeyError:
                pass
        elif (eventtype == "SMS"):
            try:
                chattext = ""
                for i in range(0, len(y['chat_message']['message_content']['segment'])):
                    chattype = y['chat_message']['message_content']['segment'][i]['type']
                    if (chattype == "LINE_BREAK"):
                        print("         SMS", " -", chattext)
                        chattext = ""
                    else:
                        chattext = chattext + y['chat_message']['message_content']['segment'][i]['text']
                print("         SMS", " -", chattext)
            except KeyError:
                pass
            try:
                for j in range(0, len(y['chat_message']['message_content']['attachment'])):
                    aid = y['chat_message']['message_content']['attachment'][j]['id']
                    atype = y['chat_message']['message_content']['attachment'][j]['embed_item']['type']
                    if (atype == "PLUS_PHOTO"):
                        mediatype = y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_photo']['media_type']
                        originalurl = y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_photo']['original_content_url']
                        print("         SMS",mediatype, " - URL - ", originalurl)
                        if (mediatype == "VIDEO"):
                            downloadurl = y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_photo']['download_url']
                            print("         SMS",mediatype, " - DOWNLOAD - ", downloadurl)
                        else:
                            print("")
                    else:
                        duration = y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_audio_v2']['duration']
                        originalurl = y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_audio_v2']['url']
                        embedurl = y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_audio_v2']['embed_url']
                        print("         SMS","VOICEMAIL", " - duration - ", duration)
                        if (deliverymedium == "GOOGLE_VOICE_MEDIUM"):
                            print("         SMS","VOICEMAIL", " - Check Google Voice Takeout for the mp3 file - ")
                        else:
                            print("         SMS","VOICEMAIL", " - Check your phone service for the mp3 file - ")
            except KeyError:
                pass
        elif (eventtype == "VOICEMAIL"):
            try:
                chattext = ""
                for i in range(0, len(y['chat_message']['message_content']['segment'])):
                    chattype = y['chat_message']['message_content']['segment'][i]['type']
                    if (chattype == "LINE_BREAK"):
                        print("     VOICEMAIL", "Transcript -", chattext)
                        chattext = ""
                    else:
                        chattext = chattext + y['chat_message']['message_content']['segment'][i]['text']
                print("     VOICEMAIL", " -", chattext)
            except KeyError:
                pass
            try:
                for j in range(0, len(y['chat_message']['message_content']['attachment'])):
                    aid = y['chat_message']['message_content']['attachment'][j]['id']
                    atype = y['chat_message']['message_content']['attachment'][j]['embed_item']['type']
                    duration = y['chat_message']['message_content']['attachment'][j]['embed_item']['plus_audio_v2']['duration']
                    print("     VOICEMAIL", " - duration - ", duration)
                    if (deliverymedium == "GOOGLE_VOICE_MEDIUM"):
                        print("     VOICEMAIL", " - Check Google Voice Takeout for the mp3 file - ")
                    else:
                        print("     VOICEMAIL", " - Check Google Fi Takeout for the mp3 file - ")
            except KeyError:
                pass
        else:
            print("    Event Type Unknown")
        b += 1
        print(" ")
    print("   Conversation ID - ", x['conversation']['conversation_id']['id'],' had ',b,' message events')
    a += 1
    print(" ")

print('Total Conversations:', a)

# reset to console
sys.stdout = sys.__stdout__
sys.stderr = sys.__stderr__

print('Parsing took', time.time()-parsestart, 'seconds.')
print('Your messages should now all be copied to',textfile)
