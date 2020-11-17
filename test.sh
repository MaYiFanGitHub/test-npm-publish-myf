# #!/usr/bin/expect
# spawn npm login
# expect "Username:"
# send "mayifan\n"
# expect "Password:"
# send "9320996688\n"
# expect "Email: (this IS public)"
# send "83964472@qq.com\n"
# #interact
# expect off
# asdf
#!/bin/bash  
# (echo "mayifan" && sleep 1 && echo "qq9320996688" && sleep 1 && echo "83964472@qq.com") | npm login
git pull
if [ $? -eq 0 ]; then
echo 1
else
echo 2
fi