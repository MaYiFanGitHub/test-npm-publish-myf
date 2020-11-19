#!/usr/bin/sh
# sed -i '1i\Insert this line' file.txt 
$ sed -i '1i\ABCDE' file.txt

grep -l \'texttofind\' * | xargs sed -i '' 's/toreplace/replacewith/g'
grep -l \'texttofind\' * | xargs sed -i 's/toreplace/replacewith/g'

###2019-03-01
   FE: wangkai37
   NOTE: 新增测试组件