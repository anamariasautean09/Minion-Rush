.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod

; nu am reusit decat sa fac miscarea stanga-dreapta si sa se miste simbolurile, miscarea stanga-drepata se realizeza din controllerele aflate in fereasta iar obiectele se misca continuu
.data
;aici declaram date
window_title DB "MINION_RUSH",0
area_width EQU 750    ; dim ecran 
area_height EQU 600
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

aux dd 0
minion dd 460
symbol_width DD 10
symbol_height DD 20

symbols_elem_width DD 36     ; dimensiunile simbolurilor
symbols_elem_height DD 36
;symbols_sageti_width DD 39   ; dimensiunile sagetilor
;symbols_sageti_height DD 36

x_i_j DD 0    ; parametrii pentru parcurgerea matricii 
y_i_j DD 0
linii DD 11  ; nr liniimatrice_joc
coloane DD 11  ; nr coloanematrice_joc
zona_joc_x EQU 29     ; dimensiunile zonei de joc propriu-zisa
zona_joc_y EQU 74
zona_size_x EQU 350
zona_size_y EQU 430

start_x DD 0
start_y DD 60 

buton_x_stg EQU 500
buton_y_stg EQU 455
buton_dim_stg EQU 50

 buton_x_dr EQU 615
 buton_y_dr EQU 455
 buton_dim_dr EQU 50
 
i DD 10
j DD 0
dim DD 8
val DD 3
prima DD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 
ok DD 0			

include symbols_game.inc  ; fisierul cu simboluri
include digits.inc
include letters.inc


 
             


matrice_joc  dd 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
     	     dd 0, 2, 0, 1, 0, 0, 0, 0, 0, 1, 0  ;matrice_joc de joc
             dd 0, 0, 0, 0, 0, 1, 0, 1, 0, 2, 0
			 dd 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0
			 dd 0, 0, 0, 1, 0, 1, 0, 2, 0, 1, 0
			 dd 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0
			 dd 0, 2, 0, 1, 0, 0, 0, 1, 0, 0, 0
			 dd 0, 1, 0, 0, 0, 2, 0, 1, 0, 2, 0
			 dd 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
			 dd 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0
			 dd 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0
			 


.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_symbols_game proc     ;functia pentru crearea simbolurilor 
	push ebp
	mov ebp, esp
	pusha	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	lea esi, symbols_game
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbols_elem_width
	mul ebx
	mov ebx, symbols_elem_height
	mul ebx
	add esi, eax
	mov ecx, symbols_elem_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer lamatrice_joca de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbols_elem_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbols_elem_width
bucla_simbol_coloane:  ; colorarea simbolurilor 
    cmp byte ptr[esi], 0
	je spatiu_symbols
	cmp byte ptr[esi], 1
	je galben_symbols
    cmp byte ptr[esi], 2
	je maro_symbols
    cmp byte ptr[esi], 3
	je negru_symbols
    cmp byte ptr[esi], 4
	je albastru_symbols

	
spatiu_symbols:
	 mov dword ptr[edi], 0ffffffh
	 jmp simbol_pixel_next
galben_symbols:
	mov dword ptr[edi], 0FFE500h
	jmp simbol_pixel_next
maro_symbols:
	mov dword ptr[edi], 0804000h
	jmp simbol_pixel_next
negru_symbols:
	mov dword ptr[edi], 0000000h
	jmp simbol_pixel_next
albastru_symbols:
	mov dword ptr[edi], 00000FFh
	jmp simbol_pixel_next


simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_symbols_game endp


make_text proc
	push ebp
	mov ebp, esp
	pusha	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matrice_joc de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
	
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
make_symbols_macro macro symbols_game, drawArea, x, y
	push y
	push x
	push drawArea
	push symbols_game
	call make_symbols_game
	add esp, 16
endm

make_sageti_macro macro sageti, drawArea, x, y
	push y
	push x
	push drawArea
	push sageti
	call make_sageti
	add esp, 16
endm

line_horizontal macro  x,y, len, color  ; linie orizontala
local bucla_line
      mov eax, y ; eax = y
	  mov ebx, area_width
	  mul ebx ; eax = y * area_width
	  add eax, x ; eax = y * area_width + x
	  shl eax, 2 ; eax = (y * area_width + x) * 4 
	  add eax, area
	  mov ecx, len
bucla_line :
      mov dword ptr[eax], color
	  add eax, 4
	  loop bucla_line
endm



line_vertical macro  x,y, len, color   ; linie verticala 
local bucla_line
      mov eax, y ; eax = y
	  mov ebx, area_width
	  mul ebx ; eax = y * area_width
	  add eax, x ; eax = y * area_width + x
	  shl eax, 2 ; eax = (y * area_width + x) * 4 
	  add eax, area
	  mov ecx, len
bucla_line :
      mov dword ptr[eax], color
	  add eax, area_width * 4
	  loop bucla_line
endm

schimbare_linie_matrice proc
push ebp
mov ebp, esp
pop ebp
schimbare_linie_matrice endp	
	
delay proc   ; am incercat sa scriu o functie pt intarziere dar nu am reusit sa o folosesc
   mov cx, 003H
  delRep:
      push cx
	  mov cx, 0D090H
  delDec:
     dec cx
	 jnz delDec
	 pop cx
	 dec cx
	 jnz delRep
	 ret
delay endp

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	evt_click:
	;line_horizontal [ebp+arg2], [ebp+arg3], 100, 000000
	;line_vertical [ebp+arg2], [ebp+arg3], 100, 000000
	mov eax, [ebp+arg2]
	mov ebx, [ebp+arg3]
	cmp eax, 500
	jl exterior
	cmp eax, 550
	jg exterior
	cmp ebx, 455
	jl exterior
	cmp ebx, 505
	jg exterior

	cmp minion, 444
	je exterior
	mov edx, minion; calculam pozitia din stanga minionului
	sub edx, 8
	mov ecx,matrice_joc[edx] ; in ecx punem pozitia din stanga minionului
	mov esi, minion; in esi punem minionul
	mov edi,matrice_joc[esi]; in edi punem pozitia minionului
	mov matrice_joc [edx], edi
	mov matrice_joc[esi], ecx
	sub minion, 8
	


exterior:    ;miscarea stg-dr
mov eax, [ebp+arg2]
	mov ebx, [ebp+arg3]
	cmp eax, 615
	jl exterior1
	cmp eax, 665
	jg exterior1
	cmp ebx, 455
	jl exterior1
	cmp ebx, 505
	jg exterior1
	

	cmp minion, 476   ; pozitia initiala a minionului 
	je exterior1
	mov edx, minion; calculam pozitia din stanga minionului
	add edx, 8
	mov ecx,matrice_joc[edx] ; in ecx punem pozitia din stanga minionului
	mov esi, minion; in esi punem minionul
	mov edi,matrice_joc[esi]; in edi punem pozitia minionului
	mov matrice_joc [edx], edi
	mov matrice_joc[esi], ecx
	add minion, 8
	jmp exterior1

evt_timer:

inc counter
push eax
push ebx
push ecx
push edx

mov ecx, 11
mov ebx, 0

u:  ; mut intr-un array elem de pe prima linie a matricii de joc
mov eax, 1
mul linii
add eax, j
mul dim
mov edx, matrice_joc[eax]
mov prima[ebx], edx
add ebx, 4
inc j

loop u
mov ecx, 10

for1: ; liniile din matrice_joc vor cobori cu o pozitie mai jos
mov i, ecx
push ecx
mov ecx, 11
mov j, 0

for2:
dec i
mov eax, i
mul linii
add eax, j
mul dim
mov val, eax
inc i
mov eax, i
mul coloane
add eax, j
mul dim
mov edx, val
mov ebx, matrice_joc[edx]
mov matrice_joc[eax], ebx
inc j
loop for2

pop ecx
loop for1

mov ecx, 11
mov i, 0
mov j, 0
mov ebx, 0

p: ; completez  prima linie cu elem ce le am copiat inainte 

mov eax, i
mul coloane
add eax, j
mul dim
mov edx, prima[ebx]
mov matrice_joc[eax], edx
add ebx, 4
inc j
loop p

pop edx
pop ecx
pop ebx
pop eax
 
exterior1:

	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	;jmp afisare_litere
	

	push eax 
	push ebx
	push ecx
	push edx
	mov eax, 0
	mov ecx, 0
	
	
	mov esi, 0   ;i    ; pargurgerea matricii de joc
	mov edi, 0   ;j
	for_1: 
	mov edi, 0
	for_2: 
	mov eax, esi
	mul coloane
	add eax, edi
    mov ecx,matrice_joc[eax*4]
	
	mov eax, symbols_elem_height ; aflam x_i_j 
	mov ebx, edi
	mul ebx
	add eax, start_x
	mov x_i_j, eax
	
	mov eax, symbols_elem_height ; aflam y_i_j
	mov ebx, esi
	mul ebx
	add eax, start_y
	mov y_i_j, eax
	

	make_symbols_macro ecx, area, x_i_j, y_i_j
	inc edi
	cmp edi, coloane
	jl for_2
	inc esi
	cmp esi, linii
	jl for_1
	pop edx
	pop ecx
	pop ebx
	pop eax
	

	
	

afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	
	
	
	
	;scriem un mesaj
	make_text_macro 'M', area, 110, 40   ; scrierea titlului pe ecran
	make_text_macro 'I', area, 120, 40
	make_text_macro 'N', area, 130, 40
	make_text_macro 'I', area, 140, 40
	make_text_macro 'O', area, 150, 40
	make_text_macro 'N', area, 160, 40
	
	make_text_macro 'R', area, 180, 40
	make_text_macro 'U', area, 190, 40
	make_text_macro 'S', area, 200, 40
	make_text_macro 'H', area, 210, 40
	
	make_text_macro 'S', area, 550, 80
	make_text_macro 'C', area, 560, 80
	make_text_macro 'O', area, 570, 80
	make_text_macro 'R', area, 580, 80
	make_text_macro 'E', area, 590, 80
	
	
	make_text_macro '0', area, 560, 110
	make_text_macro '0', area, 570, 110
	make_text_macro '0', area, 580, 110
	
	make_text_macro 'C', area, 530, 400
	make_text_macro 'O', area, 540, 400
	make_text_macro 'N', area, 550, 400
	make_text_macro 'T', area, 560, 400
	make_text_macro 'R', area, 570, 400
	make_text_macro 'O', area, 580, 400
	make_text_macro 'L', area, 590, 400
	make_text_macro 'L', area, 600, 400
	make_text_macro 'E', area, 610, 400
	make_text_macro 'R', area, 620, 400
	make_text_macro 'E', area, 630, 400
	
	
	
	
	line_horizontal zona_joc_x, zona_joc_y, zona_size_x, 0    ; realizarea zonei de joc 
	line_horizontal zona_joc_x, zona_joc_y + zona_size_y, zona_size_x, 0
	line_vertical zona_joc_x, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + zona_size_x, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + 70, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + 140, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + 210, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + 280, zona_joc_y, zona_size_y, 0
   
    
     
	 ; make_symbols_macro 1, area, 66, 219   ; afisarea simbolurilor in zona de joc
	 ; make_symbols_macro 1, area, 188, 260
	 ; make_symbols_macro 1, area, 228, 360
	 ; make_symbols_macro 1, area, 108, 360
     ; make_symbols_macro 1, area, 149, 103
	 ; make_symbols_macro 1, area, 227, 117
	 ; make_symbols_macro 1, area, 148, 435
	 ; make_symbols_macro 1, area, 109, 116
	 ; make_symbols_macro 1, area, 69, 418
	 ; make_symbols_macro 1, area, 109, 254
	 ; make_symbols_macro 2, area, 188, 402
	 ; make_symbols_macro 1, area, 147, 216
	 ; make_symbols_macro 2, area, 66, 114
	 ; make_symbols_macro 2, area, 188,134
	 ; make_symbols_macro 2, area, 68, 298
	 ; make_symbols_macro 2, area, 109,166
	 ; make_symbols_macro 2, area, 148, 319
	 ; make_symbols_macro 2, area, 228, 250
	 ; make_symbols_macro 3, area, 147, 489
	 make_symbols_macro 8, area, 507, 465
	 make_symbols_macro 7, area, 622, 465
	 
	 line_horizontal buton_x_dr, buton_y_dr, buton_dim_dr, 0     ;crearea controllerlor sub forma de patrate 
	 line_horizontal buton_x_dr, buton_y_dr + buton_dim_dr, buton_dim_dr, 0
	 line_vertical	 buton_x_dr, buton_y_dr, buton_dim_dr, 0
	 line_vertical buton_x_dr + buton_dim_dr, buton_y_dr, buton_dim_dr, 0
	 
	 line_horizontal buton_x_stg, buton_y_stg, buton_dim_stg, 0
	 line_horizontal buton_x_stg, buton_y_stg + buton_dim_stg, buton_dim_stg, 0
	 line_vertical	 buton_x_stg, buton_y_stg, buton_dim_stg, 0
	 line_vertical buton_x_stg + buton_dim_stg, buton_y_stg, buton_dim_stg, 0
	 
	
	

	

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
