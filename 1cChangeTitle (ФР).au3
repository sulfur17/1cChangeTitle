#include <WinAPIProc.au3>
#include <WinAPI.au3>
#include <StringConstants.au3>
#RequireAdmin

Global $aAdjust

Func _GetHwnd($id,$txt="")   ;Retrieve Hwnd of process
    $proc = 0
    If _IsPIDOrProc($id) Then
        $proc = _PIDOrProcToHwnd($id)
    ElseIf _IsWinTitle($id,$txt) Then
        $proc = _WinTitleToHwnd($id,$txt)
    EndIf
    Return $proc
EndFunc

Func _IsPIDOrProc(ByRef $id)  ;Is running PID or Processname
    If Not ProcessExists($id) Then
        Return 0
    Else
        Return $id
    EndIf
EndFunc

Func _IsWinTitle(ByRef $id,$txt="")  ;Is running Window Title
    $win = WinGetTitle($id,$txt)
    If Not $win Then Return 0
    $id = $win
    Return 1
EndFunc

Func _IsWinVisible($handle)   ;Is Window Visible
    If BitAnd( WinGetState($handle), 2 ) Then
        Return 1
    Else
        Return 0
    EndIf
EndFunc

Func _PIDOrProcToHwnd($proc)   ;Convert PID or process to Hwnd
    If ProcessExists($proc) <> $proc Then
        $proclist = ProcessList($proc)
        $proc = $proclist[1][1]
    EndIf
    $var = WinList()
    For $i = 1 to $var[0][0]   ;Pair PID/Process with Window Title
        If $var[$i][0] <> "" AND _IsWinVisible($var[$i][1]) Then
            If WinGetProcess($var[$i][0]) = $proc Then $proc = WinGetHandle($var[$i][0])
        EndIf
    Next
    Return $proc
EndFunc

Func _WinTitleToHwnd($proc, $txt = "")   ;Convert Window title to Hwnd
    $winlist = WinList($proc,$txt)
    If Not $winlist[0][0] Then Return -1
    Return $winlist[1][1]
EndFunc

; Gives you more clear command parameter's  view, like "User = Admin" from /N"Admin"
Func _PlainExpression($sCmdLine, $sParameterPattern, $sParameterPlainName)

	$aMatches = StringRegExp($sCmdLine, $sParameterPattern, $STR_REGEXPARRAYMATCH)

	If (@error) Then
		$sPlainExpression = ""
	Else
		$sPlainExpression = $sParameterPlainName & $aMatches[0]
	EndIf

	Return $sPlainExpression

EndFunc

; Return string with really important cmd-line parameters in plain view
; example "Base = TB, User = Admin"
Func _1CImportantParametersLine($sCmdLine)

	; example: DESIGNER /IBNAME"ЦФГ ТБ (рабочая)" /APPAUTCHECKMODE
	; example /IBNAME"PK" /N"Администратор" /USEHWLICENSES+ /TCOMP -SDC /LRU /VLRU /O NORMAL
	; you can test regex at https://regex101.com

	Local $aParameters[2][2];

	$aParameters[0][0] = "" ; "Base = "
	$aParameters[0][1] = "\/IBNAME""([^""]*)"""

	$aParameters[1][0] = "" ; "User = "
	$aParameters[1][1] = "\/N""([^""]*)"""

	Local Const $iArraySize = Ubound($aParameters)
	$sResult = ""
	$sDelim = ""

	For $i = 0 To $iArraySize - 1
		$sPlainExpression = _PlainExpression($sCmdLine, $aParameters[$i][1], $aParameters[$i][0])
		If $sPlainExpression <> "" Then
			$sResult = $sResult & $sDelim & $sPlainExpression
			$sDelim = ", ";
		EndIf
	Next

	Return $sResult
EndFunc

Func ImproveMainCaption($aProcList)
	$iProcessNumer = $aProcList[0][0]
	For $i = 1 To $iProcessNumer

		$sCmdLine = StringUpper(_WinAPI_GetProcessCommandLine($aProcList[$i][1]))
		$sLine = _1CImportantParametersLine($sCmdLine)

		$ID = $aProcList[$i][1]
		WinSetTitle(_GetHwnd($ID), "", "{" & $sLine & "}")

		#comments-start
			If StringRegExp($sCmdLine, "DESIGNER") Then
				;If StringRegExp ( $List2, "COPY" ) or StringRegExp ( $List2, "TEST" ) or StringRegExp ( $List2, "ТЕСТ" ) or StringRegExp ( $List2, "КОПИЯ" ) Then
				If True Then
					;MsgBox(0,"",$list2)
					$sCmdLine = StringReplace($sCmdLine,"DESIGNER","")
					$sCmdLine = StringReplace($sCmdLine,"/IBNAME","")
					$sCmdLine = StringReplace($sCmdLine,"/APPAUTOCHECKVERSION","")
					$sCmdLine = StringReplace($sCmdLine,"/APPAUTOCHECKMODE","")
					$ID = $aProcList[$i][1]

					;$List2 = "Тестовая база " & String($List2)
					$sCmdLine = "" & $sCmdLine
					WinSetTitle(_GetHwnd($ID), "", $List2)

				EndIf
			EndIf
		#comments-end
	Next
EndFunc


;Список процессов
While 1
	$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	_WinAPI_AdjustTokenPrivileges($hToken, $SE_DEBUG_NAME, $SE_PRIVILEGE_ENABLED, $aAdjust)
	If Not (@error Or @extended) Then
		$aProcList = ProcessList("1cv8.exe")
		ImproveMainCaption($aProcList)

		$aProcList = ProcessList("1cv8c.exe")
		ImproveMainCaption($aProcList)

		_WinAPI_AdjustTokenPrivileges($hToken, $aAdjust, 0, $aAdjust)
		_WinAPI_CloseHandle($hToken)
	Else
		MsgBox(0, "Error", "Ошибка получения полномочий")
		Exit
	EndIf

	Sleep(2500)
WEnd