section .data

; so if understandf well everything works fairly well 
; ---------------------------------------------------------------------------------------
; Programme de Gestion de Personnel 
; ----------------------------------------------------------------------------------------
; Ce programme permet à l'utilisateur de gérer une liste de personnes. Il offre
; les fonctionnalités suivantes :

; ATTENTIION : -Concernant les index il faut bien mettre un 0 avant les index allant de 0 à 9 
;    -la base de données ne peut acceuillir au dela de >99 personnes , 
;                        ni agé de plus de > 99 ans
;
; 1 Enregistrer du personnel
; 2 Lister des personnes enregistrées
; 3 Afficher des personnes spécifiques
; 4 Afficher la personne la plus âgée
; 5 Quitter le programme
;
; Auteur : [Mehdi ZNATA]
; Date : [8/03/24]
; ----------------------------------------------------------------------------------------


database times 1200 db 0 

menuPrompt: db 'Choisir une option entre 1 et 5', 0xa
menuPromptLen: equ $-menuPrompt

errorPrompt: db 'Error --> invalid value !', 0xa
errorPromptLen: equ $-errorPrompt

savedPrompt: db 'Rentrer le nom et _espace_  age de la personne ', 0xa
savedPromptLen: equ $-savedPrompt

successSaved: db 'Saved', 0xa
successSavedLen: equ $-successSaved

searchPrompt: db ' inserrez index de la personne Que vous  recherchez ? ', 0xa
searchPromptLen: equ $-searchPrompt

smallInput: db 'input too small ', 0xa
smallInputLen: equ $-smallInput

largeInput: db 'input too Large ', 0xa
largeInputLen: equ $-largeInput

youngestPersonMsg: db 'Le plus jeune peronnel est:', 0xa
youngestPersonLen: equ $-youngestPersonMsg

newline : db ' ',0xa
newlineLen: equ $-newline

space : db ' '
spaceLen: equ $-space

debugMsg : db 'debugMsg',0xa
debugMsgLen: equ $-debugMsg

n dd 0

var db 0

buffer times 13 db 0

section .text
global _start
_start: ; 
    mov eax,0
    mov [n],eax
    jmp init

init :  
    xor eax,eax
    mov [var],al

    mov eax , 4
    mov ebx , 0
    mov ecx , newline
    mov edx , newlineLen
    int 80h

    mov eax , 4
    mov ebx , 0
    mov ecx , menuPrompt
    mov edx , menuPromptLen
    int 80h

    mov eax , 3
    mov ebx , 0
    mov ecx , var
    mov edx , 2
    int 80h

    cmp byte[var],'1'
    je PersonnelRegistry

    cmp byte[var],'2'
    je list

    cmp byte[var],'3'
    je print

    cmp byte[var],'4'
    je age

    cmp byte[var],'5'
    je exit

    mov eax , 4
    mov ebx , 0
    mov ecx , errorPrompt
    mov edx , errorPromptLen
    int 80h

    jmp init

PersonnelRegistry :  
    mov eax , 4
    mov ebx , 0
    mov ecx , savedPrompt
    mov edx , savedPromptLen
    int 80h

    mov eax , 3
    mov ebx , 0
    mov ecx , buffer
    mov edx , 14
    int 80h

    mov ebx , buffer
    mov edx,database

    mov ecx , [n]
    mov eax , 12
    imul ecx , eax
    add edx , ecx

    mov ah , byte[ebx]
    mov byte[edx] , ah

    inc ebx
    inc edx
    jmp PersonnelName;

PersonnelName :
    cmp byte[ebx],' '
    je PersonnelAge

    mov ah , byte[ebx]
    mov byte[edx] , ah

    inc ebx
    inc edx
    jmp PersonnelName

PersonnelAge :
    inc ebx

    mov edx , database
    mov ecx , [n]
    mov eax , 12
    imul ecx , eax
    add edx , ecx
    add edx , 10

    mov ah , byte[ebx]
    mov byte[edx] , ah
    inc ebx
    inc edx
    mov ah , byte[ebx]
    mov byte[edx] , ah
    inc ebx
    inc edx


    mov eax,[n]
    inc eax
    mov [n],eax

    jmp init

list :
    mov esi,[n]
    mov ecx,database
    jmp listing

listing :

    cmp esi , 0

    je init

    call startingPrompt

    dec esi

    jmp listing

print :   
    mov eax , 4
    mov ebx , 0
    mov ecx , searchPrompt
    mov edx , searchPromptLen
    int 80h

    mov eax , 3
    mov ebx , 0
    mov ecx , buffer
    mov edx , 14
    int 80h

    mov ebx , buffer

    mov esi,2
    xor edx,edx
    jmp conversion

conversion :
    cmp esi,0
    je printNext

    xor eax,eax
    mov al , byte[ebx]

    sub eax,'0' ;conversion en entier

    imul edx,10 ;calcul de l'entier
    add edx,eax
    

    inc ebx
    dec esi
    jmp conversion

printNext :
    cmp edx,0
    je TooSmall

    mov eax,[n]
    cmp edx, eax
    jg TooLarge

    sub edx,1

    mov ecx,database

    mov eax , 12
    imul edx , eax
    add ecx , edx

    call startingPrompt

    jmp init



TooSmall :
    mov eax , 4
    mov ebx , 0
    mov ecx , smallInput
    mov edx , smallInputLen
    int 80h
    jmp init

TooLarge :
    mov eax , 4
    mov ebx , 0
    mov ecx , largeInput
    mov edx , largeInputLen
    int 80h
    jmp init

age : 
    mov edi,database
    mov esi,[n]
    mov ebx,database
    add ebx , 10
    xor eax,eax
    jmp ageLooping

ageLooping :

    xor ecx,ecx
    mov cl,byte[ebx]
    sub ecx,'0'
    imul ecx, 10
    mov edx,ecx
    inc ebx
    mov cl,byte[ebx]
    sub ecx,'0'
    add edx,ecx

    cmp eax,edx
    jg ageChange

    add ebx,11
    dec esi
    cmp esi,0
    jne ageLooping
    jmp agePrinting

ageChange :

    mov eax,edx
    mov edi,ebx
    sub edi,11

    add ebx,11
    dec esi
    cmp esi,0
    jne ageLooping
    jmp agePrinting

agePrinting :

    mov eax , 4
    mov ebx , 1
    
    mov ecx , youngestPersonMsg
    mov edx , youngestPersonLen
    int 80h

    mov ecx,edi
    call startingPrompt
    jmp init

exit :
    mov eax , 1
    mov ebx , 0
    int 80h


startingPrompt :
    mov edi , 10

    mov eax , 4
    mov ebx , 0
    mov ecx , ecx
    mov edx , 1
    int 80h

    inc ecx
    dec edi

    jmp LoopingPrompt

LoopingPrompt :

    mov eax , 4
    mov ebx , 0
    mov ecx , ecx
    mov edx , 1
    int 80h

    inc ecx
    dec edi

    cmp edi,0
    jne LoopingPrompt

    push ecx
    mov eax , 4
    mov ebx , 0
    mov ecx , space
    mov edx , spaceLen
    int 80h
    pop ecx

    mov eax , 4
    mov ebx , 0
    mov ecx , ecx
    mov edx , 1
    int 80h

    inc ecx

    mov eax , 4
    mov ebx , 0
    mov ecx , ecx
    mov edx , 1
    int 80h

    push ecx
    mov eax , 4
    mov ebx , 0
    mov ecx , newline
    mov edx , newlineLen
    int 80h
    pop ecx

    inc ecx

    ret;