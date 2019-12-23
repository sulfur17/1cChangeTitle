#include <WinAPIProc.au3>
#include <WinAPI.au3>
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

Func _WinTitleToHwnd($proc,$txt="")   ;Convert Window title to Hwnd
    $winlist = WinList($proc,$txt)
    If Not $winlist[0][0] Then Return -1
    Return $winlist[1][1]
EndFunc


;Список процессов
While 1
 $hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
_WinAPI_AdjustTokenPrivileges($hToken, $SE_DEBUG_NAME, $SE_PRIVILEGE_ENABLED, $aAdjust)
      If Not (@error Or @extended) Then
        $aList = ProcessList("1cv8.exe")
        For $i = 1 To $aList[0][0]
          $List2 = StringUpper(_WinAPI_GetProcessCommandLine($aList[$i][1]))
          If StringRegExp ( $List2, "DESIGNER" ) Then
			If StringRegExp ( $List2, "COPY" ) or StringRegExp ( $List2, "TEST" ) or StringRegExp ( $List2, "ТЕСТ" ) or StringRegExp ( $List2, "КОПИЯ" ) Then
			   ;MsgBox(0,"",$list2)
			   $List2 = StringReplace($List2,"DESIGNER","")
			   $List2 = StringReplace($List2,"/IBNAME","")
			   $List2 = StringReplace($List2,"/APPAUTOCHECKVERSION","")
			   $List2 = StringReplace($List2,"/APPAUTOCHECKMODE","")
			   $ID =($aList[$i][1])

			   $List2 = "Тестовая база " & String($List2)
			   WinSetTitle(_GetHwnd($ID),"",$List2)

			EndIf
		 EndIf
        Next
        _WinAPI_AdjustTokenPrivileges($hToken, $aAdjust, 0, $aAdjust)
        _WinAPI_CloseHandle($hToken)
      Else
        MsgBox(0, "Error", "Ошибка получения полномочий")
		Exit
      EndIf

Sleep(2500)
WEnd