edit test
normal! VGd
for i in [1, 2, 3, 4, 5, 6, 7, 8]
  let text = 'line '.i
  :0put =text
  write
  sleep 2m
endfor
