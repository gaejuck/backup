#include <sourcemod> 
#include <sdktools> 
#include <tf2> 
#include <tf2_stocks> 
#include <morecolors> 
#include <scp> 

#define PLUGIN_AUTHOR "Arkarr" 
#define PLUGIN_VERSION "0.1" 

#define PRECISION_SEMI  1 
#define PRECISION_FULL  2 
#define PRECISION_NULL -1 


char plugintag[40] = "{green}[Chat Bot]{default}"; 
Handle Chatbot = INVALID_HANDLE; 
Handle PrintMessageTimer[MAXPLAYERS+1]; 
bool processing[MAXPLAYERS+1]; 

public Plugin myinfo =  
{ 
    name = "Simple Chat Bot", 
    author = PLUGIN_AUTHOR, 
    description = "Return simple answer when a chat string match", 
    version = PLUGIN_VERSION, 
    url = "www.sourcemod.net" 
}; 

public void OnPluginStart() 
{ 
    RegAdminCmd("sm_reloadchatbotconfig", CMD_ReloadConfig, ADMFLAG_CONFIG, "Reload the config file."); 
     
    Chatbot = CreateArray(100); 
     
    ReloadConfig(); 
} 

public OnClientDisconnect(client) 
{ 
    if (PrintMessageTimer[client] != INVALID_HANDLE) 
    { 
        KillTimer(PrintMessageTimer[client]); 
        PrintMessageTimer[client] = INVALID_HANDLE; 
    } 
} 

public Action CMD_ReloadConfig(client, args) 
{ 
    int replies = ReloadConfig(); 
     
    if(replies != -1) 
    { 
        if(client == 0) 
            PrintToServer("Loaded %i replies", replies); 
        else 
            CPrintToChat(client, "%s Loaded %i replies", plugintag, replies); 
    } 
    else 
    { 
        if(client == 0) 
            PrintToServer("Error when loaded chat bot replies !!!"); 
        else 
            CPrintToChat(client, "%s Error when loaded chat bot replies", plugintag); 
    } 
} 

public Action OnChatMessage(&author, Handle:recipients, String:name[], String:message[]) 
{ 
    for(int i = 0; i < GetArraySize(Chatbot); i += 3) 
    { 
        bool found = false; 
        char ChatbotTriger[100]; 
        GetArrayString(Chatbot, i, ChatbotTriger, sizeof(ChatbotTriger)); 
         
        if(GetArrayCell(Chatbot, i+2) == PRECISION_FULL) 
        { 
            found = StrEqual(message, ChatbotTriger, false); 
        } 
        else if(GetArrayCell(Chatbot, i+2) == PRECISION_SEMI) 
        { 
            if(StrContains(message, ChatbotTriger, false) != -1) 
                found = true; 
        } 
         
        if(found && !processing[author]) 
        { 
            char ChatbotReplie[100]; 
            GetArrayString(Chatbot, i+1, ChatbotReplie, sizeof(ChatbotReplie)); 
            Handle pack; 
            PrintMessageTimer[author] = CreateDataTimer(0.5, TMR_PrintMsg, pack); 
            WritePackCell(pack, author); 
            WritePackString(pack, ChatbotReplie); 
            processing[author] = true; 
        } 
    } 
} 

public Action TMR_PrintMsg(Handle tmr, Handle pack) 
{ 
    char str[256]; 
    int client; 
     
    ResetPack(pack); 
    client = ReadPackCell(pack); 
    ReadPackString(pack, str, sizeof(str)); 
    CPrintToChat(client, "{violet}테이크봇{default} : %s", str); 
    processing[client] = false; 
} 


public int ReloadConfig() 
{ 
    ClearArray(Chatbot); 
    Handle kv = CreateKeyValues("ChatBotReplies"); 
    FileToKeyValues(kv, "addons/sourcemod/configs/ChatBot_Replies.cfg"); 
     
    if (!KvGotoFirstSubKey(kv)) 
        return -1; 
         
    char triger[100]; 
    char replie[256]; 
    char precision[20]; 
    int precis = PRECISION_NULL; 
    int nbrreplies = 0; 
     
    do 
    { 
        KvGetString(kv, "triger", triger, sizeof(triger)); 
        KvGetString(kv, "reply", replie, sizeof(replie)); 
        KvGetString(kv, "precision", precision, sizeof(precision)); 
         
        if(StrEqual(precision, "PRECISION_FULL", true)) 
            precis = PRECISION_FULL; 
        else if(StrEqual(precision, "PRECISION_SEMI", true)) 
            precis = PRECISION_SEMI; 
             
        if(precis == -1) 
        { 
            PrintToServer("Couldn't found precision type for triger '%s'. Replies not saved.", triger); 
        } 
        else 
        { 
            PushArrayString(Chatbot, triger); 
            PushArrayString(Chatbot, replie); 
            PushArrayCell(Chatbot, precis); 
            nbrreplies++; 
        } 
         
    }while (KvGotoNextKey(kv)); 
    CloseHandle(kv);   
     
    return nbrreplies; 
}  
