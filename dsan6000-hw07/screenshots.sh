git pcd ~/Desktop/dsan6000-hw07
pkill -f "ssh -fN -L 8080" 2>/dev/null
ssh -fN -L 8080:localhost:8080 -L 4040:localhost:4040 DSAN6000
sleep 2
CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$CH" --headless=new --disable-gpu --hide-scrollbars --window-size=1400,1000 --virtual-time-budget=8000 --screenshot="$PWD/images/master-ui.png" http://localhost:8080/ 2>/dev/null
"$CH" --headless=new --disable-gpu --hide-scrollbars --window-size=1400,1000 --virtual-time-budget=15000 --screenshot="$PWD/images/session-ui.png" http://localhost:4040/executors/ 2>/dev/null
ls -la images/
