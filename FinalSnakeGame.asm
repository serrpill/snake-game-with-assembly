


data segment
    welcomeMessage db 09h, 13, 10, 13, 10
                   db 09h, 09h, "YILAN OYUNUNA HOS GELDINIZ!!", 13, 10
                   db 09h, "Bu oyunda yilanin ekranda gorulen elmalari yemesi gerekmektedir.", 13, 10
                   db 09h, "Ne kadar elma yerse o kadar buyur ve puaniniz artar.", 13, 10
                   db "Engellerden uzak durmali ve yilanin kendisine degmemesini saglamalisiniz.", 13, 10
                   
    goodLuckMessage db 09h, 13, 10
                   db 09h, "Hayatta kalmak icin 3 sansiniz var! BASARILAR..", 13, 10, "$"
    creatorMessage db 13, 10
                   db 09h, "Bu oyun Serrpill tarafindan proje icin yapilmistir.", 13, 10, "$" 
    yukari db 09h, "yukari gitmek icin  --> W ", 13, 10, "$" 
    asagi db 09h, "asagi gitmek icin  --> S ", 13, 10, "$"
    saga db 09h, "saga gitmek icin  --> D " , 13, 10, "$"
    sola db 09h, "sola gitmek icin  --> A ", 13, 10, "$"              
    
    selectLvl db 09h, "Lutfen bir seviye seciniz:   1: kolay  2: orta  3: zor", 13, 10, 13, 10, "$"               
    selectedLevel db ?
    userInput db ?
    invalidMessage db 09h, 13, 10
                   db "Gecersiz giris! Lutfen 1, 2 veya 3 tuslarindan birine basin.", 13, 10, "$"
    level1_msg db 09h, "En kolay seviye secildi.. OYUN HIZI: MIN ", "$"
    level2_msg db 09h, "Orta seviye secildi.. OYUN HIZI: NORMAL " , "$"
    level3_msg db 09h, "En zor seviye secildi.. OYUN HIZI: MAX " , "$" 
    start_game db "Oyuna baslamak icin herhangi bir tusa basiniz...", "$"  
    hlths db "Lives:",3,3,3 ;3= ascii kalp sembolu
    
    ;meyve konumlandirmalari
    letadd dw 09b4h,0848h,06b0h,01E8h,05c6h,0334h,07a0h,022ah,0a58h,0b56h,0446h,0c6ah  DUP(12, 0) ; 12 tane 0 ile baþlatýlmýþ deðer
    dletadd dw 09b4h,0848h,06b0h,01E8h,05c6h,0334h,07a0h,022ah,0a58h,0b56h,0446h,0c6ah DUP(12, 0) ; 12 tane 0 ile baþlatýlmýþ deðer
    letnum db 12            ;toplanacak meyve sayisi
    fin db 12               ;meyve sayisini takip eder
    hlth db 6               ;can sayisinin sabit kalmasini saglar
    
    ;yilan bilgileri            
    sadd dw 0478h,13 Dup(0) ;yilanin kafasinin konumu
    snake db 'O',13 Dup(0)  ;yilanin kafa karakteri
    snakel db 1             ;toplanan meyve sayisi
    
    ;galibiyet yazisi 
    gmwin dw '  ',0ah,0dh
    dw ' ',0ah,0dh
    dw ' ',0ah,0dh
    dw ' ',0ah,0dh
    dw "                       ______________________________",0ah,0dh
    dw "                      |                              |",0ah,0dh
    dw "                      |          :::::::::            |",0ah,0dh 
    dw "                      |          :YOU WIN:            |",0ah,0dh
    dw "                      |          :::::::::            |",0ah,0dh
    dw "                      |                              |",0ah,0dh                   
    dw "                      |          TEBRIKLER           |",0ah,0dh   
    dw "                      | BIR DAHAKI SEFERE GORUSURUZ  |",0ah,0dh
    dw "                      |                              |",0ah,0dh
    dw "                      |   Cikmak icin esc basiniz... |",0ah,0dh
    dw "                      |______________________________|",0ah,0dh 
    dw '$',0ah,0dh
    
    ;maglubiyet yazisi   
    gmov dw '  ',0ah,0dh
    dw ' ',0ah,0dh
    dw ' ',0ah,0dh
    dw ' ',0ah,0dh
    dw "                       ______________________________",0ah,0dh
    dw "                      |                              |",0ah,0dh
    dw "                      |         :::::::::::           |",0ah,0dh 
    dw "                      |         :GAME OVER:           |",0ah,0dh
    dw "                      |         :::::::::::           |",0ah,0dh
    dw "                      |                              |",0ah,0dh                   
    dw "                      |       BASARISIZ OLDUN        |",0ah,0dh   
    dw "                      | BIR DAHAKI SEFERE GORUSURUZ  |",0ah,0dh
    dw "                      |                              |",0ah,0dh
    dw "                      |   Cikmak icin esc basiniz... |",0ah,0dh
    dw "                      |______________________________|",0ah,0dh 
    dw '$',0ah,0dh 
          
        
          
    
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
   
    mov ax, data
    mov ds, ax
    
    mov ax,0b800h
    mov es, ax 
    
    cld ;clear Direction Flag
      
    
    call main_menu           ;giris ekrani yazilari yazdirilir
    
    startag:
                      
    call game_screen         ;oyun ekrani, sinirlar, can gostergesi, yilan ve meyveler burada olusturulur
    
    xor cl,cl 
    xor dl,dl 
    
    
    ;yilani kontrol edecek a,s,d,w komutlari buradan okunur
    read: 
    mov ah,1                ;klavyeden bir karakter girisi alir
    int 16H        
    jz s1                   ;hicbir deger girilmemisse s1e gec  
    
    mov ah,0
    int 16H
    and al,0dfh             ;kucuk/buyuk harf kabul edilmesini saglar->Caps Lock durumu temizlenir
    mov dl,al
    jmp s1
    
    s1:                     ;esc kontrol
    cmp dl,1bh              ;DLdeki karakter,1B degerine esit mi(decimal 27-ESC ASCII kodu)
    je ext                  ;oyle ise ext e git
    
    left:                   ;once soldan baslar sirayla sol-sag-yukari-asagi kontrolleri yapilir
    cmp dl,'A'
    jne right
    call moveLeft           ;A basilmissa moveLeft cagirilir
    mov cl,dl
    jmp read                ;tekrar okuma
    
    right:
    cmp dl,'D'
    jne up
    call moveRight          ;D basilmissa moveRight cagirilir
    mov cl,dl
    jmp read                ;tekrar okuma
    
    up:
    cmp dl,'W'
    jne down
    call moveUp             ;W basilmissa moveUp cagirilir
    mov cl,dl
    jmp read                ;tekrar okuma
    
    down:
    cmp dl,'S'
    jne read1
    call moveDown           ;S basilmissa moveDown cagirilir
    mov cl,dl
    jmp read                ;tekrar okuma
    
    read1:                  ;bu tuslardan baska tusa basildiysa tekrar oku
    mov dl,cl
    jmp read
    
    
    ;cikis yapilir
    ext:
    xor cx,cx
    call clearScreen        ;ekran temizlenir
    
    mov ax, 4c00h           ;sistemden cikis
    int 21h    
ends 


main_menu proc 
    
    mov ah, 09h
    lea dx, welcomeMessage
    int 21h
    
    
    mov ah, 09h
    lea dx, yukari
    int 21h 
    
    mov ah, 09h
    lea dx, asagi
    int 21h
    
    mov ah, 09h
    lea dx, saga
    int 21h
    
    mov ah, 09h
    lea dx, sola
    int 21h
    
    call selection               ;secim ekrani cagirilir
    call afterSelection          ;secimden sonra gelecek yazilar yazilir
    call clearScreen
     
ret
endp  
      
      
selection proc   
    
    mov ah, 09h
    lea dx,selectLvl             ;seviye secimi yazisi
    int 21h    
    
    mov ah, 01h                  ;kullanicidan seviye secimi alinir
    int 21h
    mov userInput, al  
    
    cmp userInput, '1'           ;ilgili seviyenin yazisi yazdirilir
    je level1
    cmp userInput, '2'
    je level2
    cmp userInput, '3'
    je level3

    ;gecersiz giris
    call clearScreen             ;giris gecersizse ekrani tamizle
    
    mov ah, 02h                  ;Imlec konumlandirilir
    mov bh, 00h                  ;Ekran numarasi BH'ye yuklenir (genellikle 00h, birincil ekran).
    mov dh, 02h                  ;Y
    mov dl, 04h                  ;X
    int 10h                      
    
    mov ah, 09h                  ;gecersiz giris yazisi
    lea dx, invalidMessage
    int 21h
                                 
    jmp selection                ;giris gecerli olana kadar devam et
    
    
    level1:
        mov ah, 09h
        lea dx, level1_msg
        int 21h
        
        mov selectedLevel, 1 
        ret

    level2:
        mov ah, 09h
        lea dx, level2_msg
        int 21h
        
        mov selectedLevel, 2  
        ret
        

    level3:
        mov ah, 09h
        lea dx, level3_msg
        int 21h
        
        mov selectedLevel, 3 
        ret
        
selection endp       


afterSelection proc  

        mov ah, 09h
        lea dx, goodLuckMessage
        int 21h

        mov ah, 09h
        lea dx, creatorMessage
        int 21h  
        

        mov ah, 09h
        lea dx, start_game           ; Oyuna baslamak icin bir tusa bas
        int 21h                             
        
        
        mov ah, 08h                  ; Gelismis klavyeden veri alma hizmeti 
        int 21h                      ; Klavye arabelleginde karakter varsa alir

        call clearScreen             ; Ekran temizlendi
        
ret        
afterSelection endp

 
game_screen proc 
    
    call border                      ;sinirlar olusturulur
    
    lea si, hlths                    ;can gostergesi olusturulur
    mov di, 0 
    mov cx, 9                        ;dongu sayisi -> canlar : = 8+1
    can:
    movsb 
    inc di
    loop can
       
    ;yilan baslangic konumuna yazildi
    xor dx,dx                        ;dx sifirlanir
    mov di,sadd                      ;di -> yilan kafasinin ilk adresi
    mov dl,snake                     ;dl -> yilan kafasinin karakteri
    es: mov [di],dl                  ;adresteki degere karakteri yazdik
    
    ;meyveler adreslerine gore atandi
    es: mov [09b4h],'*'
    es: mov [0848h],'*'
    es: mov [06b0h],'*' 
    es: mov [01E8h],'*'
    es: mov [05c6h],'*'
    es: mov [0334h],'*'
    es: mov [07a0h],'*' 
    es: mov [022ah],'*'
    es: mov [0a58h],'*'
    es: mov [0b56h],'*'
    es: mov [0446h],'*' 
    es: mov [0c6ah],'*'
    ret
endp  


moveLeft proc                       ;sola hareket saglar
    push dx                         ;dx te klavyeden girilen harf tutulur-> stackte saklar
    call shift_adres                ;yilan adres kaydirma islemi burada
    sub sadd,2                      ;yilani soldaki adrese yonlendirir  -> 2 bit cikarir
    
    call eat                        ;meyve yeme kontrolu
    
    call move_snake
    pop dx
ret    
endp

moveRight proc                      ;saga hareket saglar
    push dx 
    call shift_adres
    add sadd,2                      ;yilani sagdaki adrese yonlendirir  -> 2 bit ekler
    
    call eat
    
    call move_snake 
    
    pop dx
    
ret    
endp

moveUp proc                         ;yukari hareket saglar
    push dx 
    call shift_adres
    sub sadd,160                    ;yilani yukaridaki adrese yonlendirir  -> 160 bit cikarir
    
    call eat
    
    call move_snake
    pop dx
ret    
endp

moveDown proc                       ;asagi hareket saglar
    push dx 
    call shift_adres
    add sadd,160                    ;yilani asagidaki adrese yonlendirir  -> 160 bit cikarir
    
    call eat
    
    call move_snake
    pop dx
ret    
endp

shift_adres proc
    push ax                         ; ax'i koru
    push cx                         ; cx'i koru

                                    ; Seviyeye gore dongu tekrar sayisini ayarla
    mov al, [selectedLevel]         ; Seviye degerini al
    cmp al, 3                       ; Seviye 3 ise
    je level_3
    cmp al, 2                       ; Seviye 2 ise
    je level_2
    jmp level_1                     ; Seviye 1 veya baska bir deger ise

level_3:                            ; Normal hiz
    mov cx, 1                       ; Dongu tekrar sayisi 1
    jmp loop_seviye

level_2:                            ; Biraz daha yavas
    mov cx, 2                       ; Dongu tekrar sayisi 2
    jmp loop_seviye

level_1:                            ; Daha da yavas
    mov cx, 3                       ; Dongu tekrar sayisi 3
    jmp loop_seviye

loop_seviye:
    push bx                         
    push dx                         
    push cx
    xor ch, ch
    xor bh, bh                      ;orn: ilk turda;
    mov cl, snakel                  ; cl de yenilen meyveler tutulur (1)
    inc cl                          ; 1 arttirir (cl->2)
    mov al, 2                       ; al->2
    mul cl                          ; al->4
    mov bl, al                      ; bl->4

    xor dx, dx

                                    ; Temel hareket islemi burada gerceklesir
    shiftsnake:
    mov dx, sadd[bx-2]
    mov sadd[bx], dx                ; Gidilecek sonraki adrese, onceki adresteki deger atanir
    sub bx, 2
    loop shiftsnake                 ;yilanin tum elemanlari kaydirilana kadar devam eder
    
    pop cx
    pop dx                    
    pop bx                    

    loop loop_seviye
                                    ;en son stackten cikarilmasi gerekenler burada cikarilir
end_level_check:
    pop cx                          ; cx'i geri yükle
    pop ax                          ; ax'i geri yükle
    ret
endp

border proc                         ; sinirlar çcizilir
    mov ah, 0                       ;(ekran=25)
    mov al, 3                       ;(ekran=80)
    int 10h
    
    mov ah, 6
    mov al, 0 
    mov bh, 0ffh 
                                    ;Ust sinir
    mov ch, 2                       ; ybas         
    mov cl, 0                       ; xbas   x= 2-2
    mov dh, 2                       ; ybitis y= 0-79
    mov dl, 79                      ; xbitis
    int 10h    
                                    ;Alt sinir
    mov ch, 23        
    mov cl, 0                       ;y= 2-2   
    mov dh, 23                      ;x= 0-79  
    mov dl, 79     
    int 10h
    
                                    ;Sol sinir
    mov ch, 2               
    mov cl, 0                       ;y= 2-23
    mov dh, 23                      ;x= 0-0
    mov dl, 0
    int 10h
    
                                    ;Sag sinir
    mov ch, 2
    mov cl, 79                      ;y= 2-23
    mov dh, 23                      ;x= 79-79
    mov dl, 79
    int 10h
    
    ret
endp 


                                    ;meyve yeme ve duvara carpma kontrolleri
eat proc 
    push ax 
    push cx                         ;stacke ekler ve gecici olarak saklar 
    
    mov di,sadd                     ;sadd -> yilanin basinin bellek adresi
    es: cmp [di],0       
    jz no                           ;yilanin basinin konumunda karakter yoksa no ya atla
    es: cmp [di],20h                ;20h -> bosluk karakteri
    jz wall                         ;yilanin suanki konumundaki karakter bosluksa(duvar degil) wall a atla
    xor ch,ch                       ;ch ve cl kaydi dongude kullanilacagindan sifirlandi
    mov cl,letnum                   ;letnum -> toplanacak harf sayisi, cxe atandi
    xor si,si                       ;si sifirlandi
    lop:
    cmp di,letadd[si]               ;harflerin konumlarinin bulundugu diziye baslangic adresi atar
    jz addf                         ;yilanin basi harf adresine esitse addf ye gec
    add si,2                        ;degilse sonraki harfin adresine gec, kontrol et
    loop lop                        ;dongu cl-1, hala 0dan buyukse lopa don
    jmp wall                        ;yilanin konumu herhangi bir harf konumuna esit degilse walla atla
    
    
    ;meyve yedi
    addf:
    mov letadd[si],0                ;yilanin yedigi meyvenin adresini sifirlar, ekrandan siler
    xor bh, bh
    mov bl, snakel                  ;bx kaydini sifirlar ve bl kaydina yilanin parca sayisini atar
    es: mov dl, [di]                ;yenen meyvenin karakterini dl'ye yukler
    mov snake[bx], dl               ;yenen karakteri yilanin dizisine ekler
    es: mov [di], 0                 ;ekrandaki meyvenin bulundugu hucreyi sifirlar
    add snakel, 1                   ;yilan parca sayisini 1 arttirir cunku meyve yedi
    sub fin, 1                      ;kalan meyve sayisini 1 azalt1r
    cmp fin, 0                      ;ekranda meyve kalmadiysa kontrol islemine atla
    jz win
    jmp no                          ;islem tamam
    
    ;oyunun disina cikip cikmadigini kontrol eder
    wall:
    cmp di,320                      ;320den kucukse(sol sinir)
    jbe wallk                       ;wallk cagirilir  jbe -> below or equal
    cmp di,3840                     ;3840dan buyukse(sag sinir)
    jae wallk                       ;wallk cagirilir  jae -> above or equal
    mov ax,di                       ;yilan konumunu axe atar
    mov bl,160                      ;yukseklik
    div bl                          ;ax/bl -> bolen-al , kalan-ah
    cmp ah,0                        ;kalan sifirsa ust siniri asmis
    jz wallk
    mov ax,di
    add ax,2                        ;oyun alaninin altina gecer
    mov bl,160
    div bl
    cmp ah,0                        ;kalan sifirsa alt siniri asar
    jz wallk
    jmp no
    
    
    ;oyunun disina cikildiysa;
    wallk:
    xor bh,bh                       ;bx sifirlanir
    mov bl,hlth                     ;blye can degerleri atanir
    es: mov [bx+10],0               ;ekranda canlardan birini siler
    mov hlths[bx+2],0               ;canlarin tutuldugu diziden birini cikarir
    sub hlth,2
    cmp hlth,0                      ;canlar sifirlanmadiysa
    jnz restart                     ;tekrardan baslat
    pop cx
    pop ax
    call game_over                  ;sifirlandiysa oyunu bitirme cagrisi
    rest: 
    pop cx
    pop ax
    call restart
     
    no:
    pop cx
    pop ax
ret
endp

                                    
move_snake proc                     ;shift_adres prosedurunde adresleri kaydirilan karakterleri bu adreslere yazar
    xor ch,ch
    xor si,si
    xor dl,dl
    mov cl,snakel
    xor bx,bx
    karakter:
    mov di,sadd[si]                 ;yilanin parcalarinin adreslerini di ye atar
    mov dl,snake[bx]                ;yilan parcalarinin sembolik degerlerini dl ye atar
    es: mov [di],dl                 ;adreslere karakterleri yerlestirir
    add si,2                        ;bir sonraki adrese gecer
    inc bx                          ;bir sonraki karaktere gecer
    loop karakter
    mov di,sadd[si] 
    es:mov [di],0                   ;son yilan parcasinin adresini temizler -> iz birakmasin diye
ret
endp



restart proc                        ;duvara carptiysa ve can sifir degilse tekrar baslar
    xor ch,ch  
    xor si,si
    mov cl,snakel
    inc cl
    sifirla: 
    mov di,sadd[si]
    es:mov [di],0                   ;yilanin sahip oldugu adresleri sifirlar
    add si,2
    loop sifirla
       
    mov fin,4

                                    ;yilani tekrar tanimliyor
    mov sadd,0478h
    mov cl,snakel
    inc cl
    xor si,si
    inc si
    xor di,di
    add di,2
    bos:
    mov snake[si],0                 ;yilanin adreslerinin temizlendigini kontrol eder
    mov sadd[di],0
    add di,2
    inc si
    loop bos
    mov snakel,1
    
    xor ch,ch
    mov cl,letnum
    xor si,si
    reslet:
    mov bx,dletadd[si]              ;meyve karakterlerinin adresleri alinir
    mov letadd[si],bx
    add si,2
    add bx,2
    loop reslet      
    xor si,si
    mov snake[si],'O'               ;yilan karakteri tekrar olusturulur

    jmp startag                     ;basa don

endp

win proc                            ;kazanma senaryosu
    call clearScreen                ;ekran temizlenir
    call border                     ;sinirlar cizilir
     
    mov ah, 09h
    mov dh,0
    mov dx, offset gmwin            ;galibiyet yazisi yazilir
 
    int 21h
    

                                    ;esc basilma durumu kontrol edilir
    esc:         
    mov ah,7
    int 21h
    cmp al,1bh         
    jz ext                          ;basilirsa ext e gidilir sistemden cikis
    jmp esc
    
    ret
endp  


game_over proc                      ;kaybetme senaryosu
    call clearScreen
    call border
    
    mov ah, 09h
    mov dh,0
    mov dx, offset gmov             ;maglubiyet yazisi yazilir
    int 21h
    
     
    
    esc1:         
    mov ah,7
    int 21h
    cmp al,1bh         
    jz ext
    jmp esc1
    
endp

clearScreen proc                    ;ekran temizleme islevi
    
    xor cx,cx
    mov dh,24
    mov dl,79
    mov bh,7
    mov ax,700h
    int 10h 
    
ret
endp    

    
end start .
