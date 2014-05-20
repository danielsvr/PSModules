function proc(){
#param(
#  $action
#)
    
  gwmi Win32_Process 
  #-Filter "name = 'java.exe'" | select CommandLine,ProcessId | Format-List
}
