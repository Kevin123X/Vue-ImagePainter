git add .
    set yyyy=%date:~,4%
    set mm=%date:~5,2%
    set day=%date:~8,2% 
    set "YYYYmmdd=%yyyy%%mm%%day%"
    set "YYYYmmdd=%YYYYmmdd: =0%"
    echo "YYYYmmdd%YYYYmmdd%YYYYmmdd"
    set hh=%time:~0,2%
    set mi=%time:~3,2%
    set ss=%time:~6,2% 
    set "hhmiss=%hh%%mi%%ss%"
    set "hhmiss=%hhmiss: =0%"
    echo "hhmiss%Time%hhmiss"
    echo %hhmiss%
    set "hhmiss=%hhmiss::=0%"
    set "hhmiss=%hhmiss: =0%"
    set "timestamp=%YYYYmmdd%%hhmiss%"
set /p input=更新：
git commit -m  "%timeStamp%%input%"
git push

goto exit