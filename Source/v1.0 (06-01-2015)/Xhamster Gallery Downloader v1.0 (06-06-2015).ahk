/*
 * Xhamster Gallery Downloader v1.0 (06-01-2015)
 *
 * 2015, by SATIR-BATRAN
 *
 * Id: Xhamster Gallery Downloader v1.0 (06-01-2015), by SATIR-BATRAN
 * 
 * 
 *   HOME: http://xhamster.com/user/SATIR-BATRAN
 *   BLOG: http://xhamster.com/user/SATIR-BATRAN/blog/1.html
 *	 
 */
 
#SingleInstance force
SetBatchLines, -1 

a1:=">> Xhamster Gallery Downloader <<"
a2=v1.0 (06-01-2015)
a3=by SATIR-BATRAN
lg:=strlen(a1)
about:= StrSet(a1, lg, 2 ) . "`n" . StrSet(a2, lg+14, 2 )  . "`n" . StrSet(a3, lg+14, 2 )

menu, tray, icon, icon.ico
menu, tray, tip, %about%
;=============================
path:=a_WorkingDir . "\"
temp_n_dwn_dir:=a_WorkingDir . "\"
file_1:=a_temp . "\XHM_tmp_dwn_1.txt"
file_2:=a_temp . "\XHM_tmp_dwn_2.txt"
file_3:=a_temp . "\XHM_tmp_dwn_3.txt"
file_4:=a_temp . "\XHM_tmp_dwn_4.txt"
file_5:=a_temp . "\XHM_tmp_dwn_5.txt"
file_6:=a_temp . "\XHM_tmp_dwn_6.txt"
;=============================
;=============================
Menu, Tray, NoStandard 
Menu, Tray, Add , H&ome page, Homepage 
Menu, Tray, Add , B&log page, Blogpage 
Menu, Tray, Add , Source code & updates page, Sourcecodepage
menu, tray, add  
Menu, Tray, Add , E&xit, ButtonExit

;--------GUI---------
gui,destroy
Gui,Add,Text,y-5,`t
Gui,Add,Picture,x55 y3,icon.ico
Gui,Font,Bold
Gui,Add,Text,x+10 yp+10,Xamster Gallery Downloader 
Gui,Font,normal italic
Gui,Add,Text,xp+20 yp+15,v1.0 , 06-01-2015%a_space%

Gui,Font,normal
Gui,Font,Bold s7,verdana
Gui,Add,Text,x10 yp+30,Usage :

;;;;;;;;;;;;;;;;;;;;;;
help=
(
1. Right-cick on any of xhamster picture, gallery, or even a 
picture from feeds;

2. Select "Copy Link Location" ( NOT "Copy image Location" !);

3. Paste it here and this is it!

You will get all the pictures from a gallery, in any of above cases.

When its all done, check down in the taskbar. 
The gallery opens in minimized window.

The connection can be stopped by pressing F3. 
It will close the program too.
)

gui, font, s7 w1 normal, Verdana  ; Set 12-point Verdana.
Gui, Add, Text,x10 yp+15,%help%

Gui,Font,normal
Gui,Font,Bold s7,verdana
Gui,Add,Text,x10 yp+177,Enjoy it :


Gui, Add, Edit,xp yp+15 hwndEC1 R1 w320 vMyEdit

gui, font, s7 w700, Verdana  ; Set 12-point Verdana.
Gui, Add, Button, default x80 h20 w200 gDownload, &Download gallery

gui, font, s7 W1  ITALIC, Verdana  ; Set 12-point Verdana.
Gui, Add, Text,x65,%about%
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Gui,Font, s7,verdana
Gui,Add,Text,x30 yp+1,This program is freeware and it is made by SATIR-BATRAN.
Gui,Add,Text,xp yp+12,For more information, please stop by at :
Gui,Font,s7 CBlue Underline italic, verdana
Gui,Add,Text,xp yp+13 gHomepage,http://xhamster.com/user/SATIR-BATRAN
Gui,Add,Text,xp yp+12 gBlogpage,http://xhamster.com/user/SATIR-BATRAN/blog/1.html
Gui,Add,Text,xp yp+12 gSourcecodepage,http://source codes


Gui,   -Caption +sysmenu -resize +0xC00000 +e0x1000
Gui, Show, ,Xhamster Gallery Downloader v1.0%a_space%%a_space%%a_space%
Gui, Submit, nohide
OnMessage(0x111,"WM_Command")
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE")

return

ButtonExit:
GuiClose:
	ButtonOK:
	Gui, Submit  ; Save 
	gui,destroy
	exitapp
return
	
f3::exitapp

WM_Command(wp,lp) {
 global EC1, EC2
 If (lp=EC1 OR lp=EC2) AND (wp>>16 = 0x100)  ;EN_SetFocus
  PostMessage, 0xB1,,-1,,ahk_id %lp%         ;EM_SetSel
}

download:
	GuiControlGet, input,, MyEdit  
	gosub BEGIN
return	

;-----------------


BEGIN:
input=%input%
input:=Validate(input)
	if	!input
	{
		msgbox,48, Ups,Not valid`, try again!
	}else{
		if !IsInternetConnected()
		{
			msgbox,48, Ups,No internet connexion !
		}else{
			gosub FIRST_PG_DWN
			gosub PARSER_0
			gosub PARSER_1
			gosub PARSER_2
			gosub MORE_PAGES
			gosub PICS_DWN
			gosub CLEANUP
		}
	}
	return
	

FIRST_PG_DWN:
	CoordMode, ToolTip
	Tooltip, Connecting...,0,305	
	SoundBeep  4750	
	UrlDownloadToFile, %INPUT%, %file_1%
	Tooltip
return

PARSER_0:
	Pos := 0, res := ""
	FileRead, html, %file_1%	
	While Pos := RegExMatch(html, "href=(\S*)\.(html|htm)", m, Pos + 1) 
	{
		StringTrimLeft, m, m, 6
		res .= m "`n"
	}
	FileDelete, %file_2%
	FileAppend, %res%, %file_2%
return


PARSER_1:
	FileReadLine, numar_gall_name, %file_2%, 1
	t1:="http://xhamster.com/photos/gallery/" 
	RegExMatch(numar_gall_name, "ims)" . t1 . "(.+?)/(.+?)\.", SubPat)
	gall_nr=%subpat1%
	gall_name=%subpat2%

	t1:="http://xhamster.com/photos/view/"  . gall_nr
	res := ""
	Loop, read, %file_2%
	{
		IfInString, A_LoopReadLine, %t1%
		res.=A_LoopReadLine "`n"
	}	
	StringTrimRight, res, res, 1
	FileDelete, %file_3%
	FileAppend, %res%, %file_3%
return

PARSER_2:
	t1:="http://xhamster.com/photos/view/"  . gall_nr
	
	res := ""
	Loop, read, %file_3%
	{
		RegExMatch(A_LoopReadLine, "ims)" . t1 . "-(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d).", Su)
		big_pic:="http://ep.xhamster.com/000/0" . su1 . su2 . "/" . su3 . su4 . su5 . "/" . su6 . su7 . su8 . "_1000.jpg"
		res.=big_pic "`n"
	}	

	StringTrimRight, res, res, 1
	FileDelete, %file_4%
	FileAppend, %res%, %file_4%
return

MORE_PAGES:
	t1:="http://xhamster.com/photos/gallery/" . gall_nr . "/" . gall_name . "-"
	
	res := ""
	Loop, read, %file_2%
	{
		RegExMatch(A_LoopReadLine, "ims)" . t1 . "(\d).html", Su)
		pg_nr:=su1
		if !(pg_nr="")
		{
			res.=pg_nr "`n"
		}
	}	

	StringTrimRight, res, res, 1
	Sort, res, U
	FileDelete, %file_5%
	FileAppend, %res%, %file_5%

	Loop, read, %file_5%
		last_line := A_LoopReadLine  
	gall_no_of_pgs=%last_line%

		if (gall_no_of_pgs="")
		{
			FileRead, pic_list, %file_4%
			FileDelete, %file_6%
			FileAppend, %pic_list%, %file_6%
			return			
		}
	pic_list:=""
	loop, %gall_no_of_pgs%
	{
		if (a_index>1)
		{
			t2:="http://xhamster.com/photos/gallery/" . gall_nr . "/" . gall_name . "-" . a_index . ".html"
			INPUT=%t2%
			Tooltip, Dnw pg %a_index%...,0,305	
			gosub FIRST_PG_DWN
			gosub PARSER_0
			gosub PARSER_1
			gosub PARSER_2
			gosub PICS_DWN
			
			last_pg:=""
			FileRead, last_pg, %file_4%
			last_pg=%last_pg%
			pic_list:=pic_list . last_pg . "`r`n"
		}ELSE{
			t2:="http://xhamster.com/photos/gallery/" . gall_nr . "/" . gall_name . ".html"
			INPUT=%t2%
			Tooltip, Dnw pg %a_index%...,0,305	
			gosub FIRST_PG_DWN
			gosub PARSER_0
			gosub PARSER_1
			gosub PARSER_2
			gosub PICS_DWN
			
			last_pg:=""
			FileRead, last_pg, %file_4%
			last_pg=%last_pg%
			pic_list:=pic_list . last_pg . "`r`n"		
		}
	}
	StringTrimRight, pic_list, pic_list, 2
	tooltip
	FileDelete, %file_6%
	FileAppend, %pic_list%, %file_6%
return




PICS_DWN:
	IfNotExist, %temp_n_dwn_dir%
		FileCreateDir, %temp_n_dwn_dir%
	
	SplitPath, URL_C_C , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	current_td:= "(" . A_DD . "-" . A_MM . "-" . A_YYYY . "_" . A_HOUR . "-" . A_MIN . "-" . A_SEC . ")" 
	StringUpper,gall_name,gall_name,T
	dwn_dir:= temp_n_dwn_dir . gall_name . "_" . current_td
	nume_baza_dir:=OutNameNoExt
	IfExist, %dwn_dir%
		FileRemoveDir,%dwn_dir%,1
	FileCreateDir, %dwn_dir%
	
	Loop, read, %file_6%
		LineCount := A_Index
		
	Loop
	{
		FileReadLine, line, %file_6%, %A_Index%
		if ErrorLevel
			break

		SplitPath, line , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive	
		current_td:= "(" . A_DD . "-" . A_MM . "-" . A_YYYY . "_" . A_HOUR . "-" . A_MIN . "-" . A_SEC . ")" 
		picture:=dwn_dir . "\" . nume_baza_dir . OutNameNoExt . "_" . current_td . "." . OutExtension
		StartTime := A_TickCount
		IfInString, line, http://ep.xhamster.com/000/0//_1000.jpg
		{
			FileRemoveDir, %dwn_dir%,
			msgbox,48, Ups,Gallery not found !
			return
		}
		UrlDownloadToFile, %line%, %picture%
		ElapsedTime := (A_TickCount - StartTime)/1000
		rem:=round((LineCount-a_index)*ElapsedTime)
		formated_time:=SecToHHMMSS(rem)
		Timp_ramas_secunde:=round((LineCount-a_index)*ElapsedTime)
		Timp_ramas_minute:=round(((LineCount-a_index)*ElapsedTime)/60)
		Timp_ramas_minute := SubStr("0000" . Timp_ramas_minute,-1) 
		Timp_ramas_ore:=round(((LineCount-a_index)*ElapsedTime)/3600)
		FormatTime, ora_cand_E_gata, % DateAdd( A_Now, Timp_ramas_minute, "m" ), H:mm	
		msg=%a_index% / %linecount%`nRemaining : %formated_time%`nEnding at : %ora_cand_E_gata%
		CoordMode, ToolTip
		tooltip, Downloading %msg%,0,305
		if (a_index=1)
			first_pic:=picture
	}
		
	FileList =  
	Loop, %dwn_dir%*.*
		FileList = %FileList%%A_LoopFileName%`n
	Sort, FileList ; The R option sorts in reverse order. See Sort for other options.
	Loop, parse, FileList, `n
	{
		first_pic:=A_LoopField
		break
	}

	FileGetSize, the_size, %first_pic%
	if (the_size>0)
		run, %first_pic% /bf ,,min
	tooltip
	CoordMode, ToolTip
	tooltip, OK`, done.`nMinimized picture opened in taskbar,0,305
	SoundBeep  4750	
	sleep 3000
	tooltip
return


CLEANUP:
	filedelete,%file_1%
	filedelete,%file_2%
	filedelete,%file_3%
	filedelete,%file_4%
	filedelete,%file_5%
	filedelete,%file_6%
return

DateAdd( datetime, number=0, units="d" ) {
	StringLeft, units, units, 1
	If units NOT IN s,m,h,d
		units := "d"
	datetime += number, %units%
	Return datetime
}

NUMAR_POZE_IN_GALERIE(file_1){
	Loop, read, %file_1%
		numar_poze_in_galerie := A_Index
	return %numar_poze_in_galerie%
}
;=============================
Validate(url_adr){
	url_adr_ret=
	IfInString, url_adr, xhamster.com/photos/view/
	{
		SplitPath, url_adr , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		RegExMatch(OutNameNoExt, "(.+?)-", SubPat)
		numar_galerie:=SubPat1
		url_adr_ret:=	"http://xhamster.com/photos/gallery/" . numar_galerie . "/index.html"
	}

	IfInString, url_adr, xhamster.com/photos/gallery/
	{
		RegExMatch(url_adr, "ims)xhamster.com/photos/gallery/(.+?)/(.+?)\.", SubPat)
		numar_galerie:=SubPat1
		nume_galerie:=SubPat2
		url_adr_ret:=	"http://xhamster.com/photos/gallery/" . numar_galerie . "/index.html"
	}
	if (url_adr_ret!="")
		return %url_adr_ret%
	else 
		return false
return 
}

SecToHHMMSS(Sec) {
	OldFormat := A_FormatFloat
	SetFormat, Float, 02.0
	Hrs  := Sec//3600/1
	Min := Mod(Sec//60, 60)/1
	Sec := Mod(Sec,60)/1
	SetFormat, Float, %OldFormat%
	Return (Hrs ? Hrs ":" : "") Min ":" Sec
}


IsInternetConnected()
{
  static sz := A_IsUnicode ? 408 : 204, addrToStr := "Ws2_32\WSAAddressToString" (A_IsUnicode ? "W" : "A")
  VarSetCapacity(wsaData, 408)
  if DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", &wsaData)
    return false
  if DllCall("Ws2_32\GetAddrInfoW", "wstr", "dns.msftncsi.com", "wstr", "http", "ptr", 0, "ptr*", results)
  {
    DllCall("Ws2_32\WSACleanup")
    return false
  }
  ai_family := NumGet(results+4, 0, "int")    ;address family (ipv4 or ipv6)
  ai_addr := Numget(results+16, 2*A_PtrSize, "ptr")   ;binary ip address
  ai_addrlen := Numget(results+16, 0, "ptr")   ;length of ip
  DllCall(addrToStr, "ptr", ai_addr, "uint", ai_addrlen, "ptr", 0, "str", wsaData, "uint*", 204)
  DllCall("Ws2_32\FreeAddrInfoW", "ptr", results)
  DllCall("Ws2_32\WSACleanup")
  http := ComObjCreate("WinHttp.WinHttpRequest.5.1")

  if (ai_family = 2 && wsaData = "131.107.255.255:80")
  {
    http.Open("GET", "http://www.msftncsi.com/ncsi.txt")
  }
  else if (ai_family = 23 && wsaData = "[fd3e:4f5a:5b81::1]:80")
  {
    http.Open("GET", "http://ipv6.msftncsi.com/ncsi.txt")
  }
  else
  {
    return false
  }
  http.Send()
  return (http.ResponseText = "Microsoft NCSI") ;ncsi.txt will contain exactly this text
}

StrSet( Str, Width, Align=0, PadChar=" " ) {      ; Align  => Left=0, Right=1, Center=2
 If ( StrLen( Str ) >= Width )              ; By SKAN / CD:12-Apr-2011 / LM:14-Apr-2011
  Return SubStr( Str,1,Width ) ; www.autohotkey.com/forum/viewtopic.php?p=436843#436843
 PL := ( Width - StrLen(Str) ) // ( Align=2 ? 2:1 )
 VarSetCapacity( S, PL * ( A_IsUnicode ? 2:1 ), 1 ),   S := SubStr( S,1,PL )
 StringReplace, S, S, % SubStr( S,1,1 ),  % PadChar := SubStr( PadChar,1,1 ), All
Return Align=2 ? SubStr( S Str S PadChar,1,Width ) :  Align=1 ?  S Str : Str S
} 

Homepage:

return

Blogpage:

return

Sourcecodepage:

return
;=============================
/*
WM_MOUSEMOVE(wParam,lParam)
{
  If( A_Gui <> 1 ) 
	Return

  Static hCurs = 0
  If( hCurs = 0 )
	hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
  
  ; Only change controls with Button or Url in their variable.
  If( InStr( A_GuiControl, "Button" ) ) or ( InStr( A_GuiControl, "Url" ) )
    DllCall("SetCursor","UInt",hCurs)
  Return
}
*/

WM_MOUSEMOVE(wParam,lParam)
{
Global hCurs
MouseGetPos,,,,ctrl
;Only change over certain controls, use Windows Spy to find them.
If ctrl in Static8,Static12,Static13,Button1
DllCall("SetCursor","UInt",hCurs)
Return
}