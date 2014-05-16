;**************************************************************
;*                                                            *      
;*  Routines de simulation de D-BUG12                         *      
;*                                                            *      
;*  Auteur : Maurice Tremblay                                 *      
;*  Date :	aoüt 2004                                         *      
;*                                                            *      
;*                                                            *      
;**************************************************************

;**************************************************************
;*                                                            *      
;*  Routines: jgetchar                                        *      
;*  Entrée:   aucune                                          *      
;*  Tâche:    lire un caractère en provenance du terminal     *      
;*  Sortie:   caractère ascii dans le registre b              *      
;*                                                            *      
;**************************************************************

Getchar:
        psha
Getchar1:        
        ldaa  SCISR1
        anda  #$20      ; RDRF = 1 ?
        beq   Getchar1

        ldab  SCIDRL    ; lecture du caractère
        pula
		rts
    

;**************************************************************
;*                                                            *      
;*  Routines: jputchar                                        *      
;*  Entrée:   registre b contient le caratère ascii           *      
;*  Tâche:    transmettre à un terminal un caractère ascii    *
;*  Sortie:   caractère ascii dans le registre b              *      
;*                                                            *      
;**************************************************************

Putchar:
        psha
Putchar1:        
        ldaa  SCISR1		
        anda  #$40		; TDRE = 1 ?
        BEQ   Putchar1
        
        clr   SCIDRH
        stab  SCIDRL    ; écriture du caractère
        pula
        rts
      

;**************************************************************
;*                                                            *      
;*  Routines: jout2hex                                        *      
;*  Entrée:   registre b contient le code hexadécimal         *      
;*  Tâche:    transmettre à un terminal la valeur ascii       *
;*            du nombre hexadécimal														*
;*  Sortie:   aucune                                          *      
;*                                                            *      
;**************************************************************

Out2hex:
        pshb		    ; sauvegarder b
        lsrb
        lsrb
        lsrb
        lsrb
        cmpb  #$0a
        bhs   lettre1   ; si plus grand ou égal c'est + 41h
        
chiffre1:
        addb  #$30      ; traduire le quartet en ascii
        bra   suitehex1
        
lettre1:
        addb  #$37      ; traduire le quartet en ascii
        
suitehex1:        
        putchar			; envoyer premier caractère
        
        pulb            ; on reprend b
        andb  #$0f      ; garger la partie basse
        cmpb  #$0a
        bhs   lettre2   ; si plus grand ou égal c'est + 41h
        
chiffre2:
        addb  #$30      ; traduire le quartet en ascii
        bra   suitehex2
        
lettre2:
        addb  #$37      ; traduire le quartet en ascii
        
suitehex2:        
        putchar			; envoyer premier caractère
        
        rts


;**************************************************************
;*                                                            *      
;*  Routines: jout4hex                                        *      
;*  Entrée:   registre d contient le code hexadécimal         *      
;*  Tâche:    transmettre à un terminal la valeur ascii       *
;*            du nombre hexadécimal														*
;*  Sortie:   aucune                                          *      
;*                                                            *      
;**************************************************************

Out4hex:
        pshd                    ; sauvegarde de d
        tab					    ; faire partie haute
        jsr Out2hex        
        puld				    ; recupérer partie basse
        jsr Out2hex     ; faire partie basse
        rts


;**************************************************************
;*                                                            *      
;*  Routines: jprintf                                         *      
;*  Entrée:   registre d contient l'adresse de départ         *      
;*  Tâche:    transmettre à un terminal un phrase de texte    *
;*            ascii terminée par un 00hex    									*
;*  Sortie:   aucune                                          *      
;*                                                            *      
;**************************************************************

Printf: pshx            ; sauvegarde de X et B
        xgdx
        
DebutPrintf:
        
        ldab 0,x
        beq   FinPrintf
        putchar 
        inx
        bra DebutPrintf
        
FinPrintf:
        pulx            ; restorer B et X         
        rts



;**************************************************************
;*                                                            *      
;*  Chargement de la table de vecteur pour la simulation      *      
;*  de D-BUG12                                                *      
;*                                                            *      
;*                                                            *      
;**************************************************************


        ORG   $FE02
        
jgetchar:  dc.w  Getchar      
jputchar:  dc.w  Putchar
jprintf:   dc.w  Printf

        ORG   $FE16
        
jout2hex:  dc.w  Out2hex
jout4hex:  dc.w  Out4hex

