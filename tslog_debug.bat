
@echo off
@CLS
@ECHO.
@chcp 936 >nul
@ECHO =========================
@ECHO ThinkStation ��־�ռ�����
@ECHO =========================
@ECHO ���������ռ���Ϣ���޹������ʹ�ã������漰���ĸ�����˽�������ʹ�ã�


@:init
@setlocal DisableDelayedExpansion
@set "batchPath=%~0"
@for %%k in (%0) do set batchName=%%~nk
@set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
@setlocal EnableDelayedExpansion

@:checkPrivileges
@NET FILE 1>NUL 2>NUL
@if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

@:getPrivileges
@if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
@ECHO.
@ECHO **************************************
@ECHO ��ȡAdministratorȨ���У�����ͬ�⣡
@ECHO **************************************

@ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
@ECHO args = "ELEV " >> "%vbsGetPrivileges%"
@ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
@ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
@ECHO Next >> "%vbsGetPrivileges%"
@ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
@"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
@exit /B

@:gotPrivileges
@setlocal & pushd .
@cd /d %~dp0
@if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

@::::::::::::::::::::::::::::
@::START
@::::::::::::::::::::::::::::
@mkdir "%cd%"\tslog
@set workpath="%cd%"\tslog
@set toolpath="%cd%"\tools
@echo �ռ�����б��У������ĵȴ���
@wmic product get name,version >%workpath%\SoftwareList.txt
@echo �ռ�BIOS��Ϣ�У������ĵȴ���
%cd%\tools\AMIDEWINx64.exe>nul 2>nul /DUMPALL %cd%\tslog\AMI_BIOS_DUMP.txt
%cd%\tools\AMIDEWINx64.exe>nul 2>nul /DMS %cd%\tslog\DMS.txt
%cd%\tools\bios\CFGWIN_x64.exe>nul 2>nul /c /path:%workpath%\bios_settings.txt
%cd%\tools\bios\SRWINx64.exe>nul 2>nul /b %workpath%\bios_settings_raw.txt
@echo ����SIO��־�У������ĵȴ���
@cd %toolpath%
@.\HwDiagWin.exe /dumplog  >>%workpath%\SIO_Events.log
@cd ..
@echo �ռ�����ϵͳ��Ϣ�У������ĵȴ���
@systeminfo >%workpath%\Systeminfo.txt
@echo �ռ�����ϵͳ��Դ�����У������ĵȴ���
@powercfg /L >%workpath%\powercfg.txt
@powercfg /Q >>%workpath%\powercfg.txt
@echo �ռ�����ϵͳ��־�У������ĵȴ���
@mkdir %cd%\tslog\oslog
xcopy %SystemRoot%\System32\winevt\Logs\* %workpath%\oslog /E/C
@echo �ռ�����ϵͳDUMP�ļ��У������ĵȴ���
@mkdir %cd%\tslog\osdump
copy %SystemRoot%\MEMORY.DMP %workpath%\osdump
xcopy %SystemRoot%\Minidump\* %workpath%\osdump /E/C
@echo �ռ�����ϵͳ�����У������ĵȴ���
@tasklist /V >%workpath%\Tasklist.txt
@echo �ռ����̷�����Ϣ�У������ĵȴ���
@wmic DISKDRIVE get model^,interfacetype^,size^,totalsectors^,partitions /value >%workpath%\Partitions.txt
@echo �ռ�Ӳ����Ϣ�У������ĵȴ���
@%cd%\tools\Devcon.exe findall * >%workpath%\Devicesinfo.txt
@echo �ռ�������Ϣ�У������ĵȴ���
@%cd%\tools\IntelVROCCli.exe -V >%workpath%\Intel_RAID_Info_VROC.txt
@%cd%\tools\IntelVROCCli.exe -I >>%workpath%\Intel_RAID_Info_VROC.txt
@%cd%\tools\rstcli64.exe -V >%workpath%\Intel_RAID_Info_RSTe.txt
@%cd%\tools\rstcli64.exe -I >>%workpath%\Intel_RAID_Info_RSTe.txt
@%cd%\tools\storcli64.exe /call/eall/sall show all >%workpath%\BCM_RAID_Info.txt
@%cd%\tools\storcli64.exe /call show events file=%workpath%\BCM_RAID_EVENT.txt
@%cd%\tools\storcli64.exe  /call show termlog >>%workpath%\BCM_termlog.txt
@echo �ռ�Ӳ��S.M.A.R.T��Ϣ�У������ĵȴ���
@%cd%\tools\smartctl.exe --scan >%cd%\tools\SMART.txt
@for /f  "tokens=1-3" %%i in (%cd%\tools\SMART.txt) do %cd%\tools\smartctl.exe -a %%i >>%workpath%\SMARTINFO.txt
@echo �ռ�NVIDIA�Կ���Ϣ�У������ĵȴ���
@%cd%\tools\nvidia-smi.exe  >%workpath%\NVIDIA_INFO.txt
@%cd%\tools\nvidia-smi.exe -a  >>%workpath%\NVIDIA_INFO.txt
@%cd%\tools\nvdebugdump.exe -D
@copy %cd%\dump.zip %workpath%\NVIDIA_dump.zip
@echo �ռ�DriextX�����Ϣ�У������ĵȴ���
@dxdiag /t %workpath%\dxdiag.txt
@echo ��־����У������ĵȴ���
@set date_str=%date:~,4%%date:~5,2%%date:~8,2%
@set time_str=%time:~,2%%time:~3,2%%time:~6,2%
@set name=%date_str%%time_str%
%cd%\tools\7-Zip\7z.exe a %cd%\%name%.7z %workpath%\
@rd /S/Q "%workpath%"
@rd /S/Q "%cd%\tools"
@del %cd%\dump.zip
@del %0