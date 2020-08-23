git add .
set timeStamp=%date:/=-%_%time%
git commit -m  "%timeStamp%"
git push
pause