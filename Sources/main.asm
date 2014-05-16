;************************************************************************* 
;*                                                                       * 
;* Auteur : Maurice Tremblay                                             * 
;* Date : avril 2007                                                     * 
;*                                                                       * 
;*                                                                       * 
;* Ce programme :                                                        * 
;*                                                                       * 
;* 1)                                                                    * 
;* affiche un message de bienvenue par une transmission                  * 
;* s�rielle de caract�res du microcontr�leur, port SCI, vers le port de  * 
;* communication COM1 d�un ordinateur personnel en �mulation de terminal * 
;* VT100.                                                                * 
;*                                                                       * 
;* 2)                                                                    * 
;* re�oit des caract�res � partir d�un clavier                           * 
;*                                                                       * 
;* 3)                                                                    * 
;* traduit des chiffres hexad�cimal en caract�re ascii pour les          * 
;* afficher sur le terminal                                              * 
;*                                                                       * 
;* 4)                                                                    * 
;* active un compteur binaire sur les DELs branch�es sur le port B       * 
;*                                                                       * 
;************************************************************************* 

; Point d'entr�e du programme

            ABSENTRY    Lab1b           ; point d'entr�e pour adressage absolu
            
            nolist                      ; D�sactiver l'insertion de texte dans le
                                        ; fichier .LST
            INCLUDE     'mc9s12c32.inc' ; Inclusion du fichier d'identification des
                                        ; registres
            INCLUDE     'D_BUG12M.MAC'  ; D�finition de macros pour des appels simples
                                        ; en assembleur ; getchar, putchar, out2hex
                                        ; out4hex, printf
            list                        ; R�activer l'insertion de texte dans le
                                        ; fichier .LST
                                        
ROMStart    EQU         $4000           ; Adresse absolue pour le d�but du programme
                                        ; et des constantes
                                        
;************************************************************************* 
;*                                                                       * 
;* D�claration des variables                                             * 
;*                                                                       * 
;* data section MY_EXTENDED_RAM � $0800                                  * 
;*                                                                       * 
;************************************************************************* 

            ORG         RAMStart
            DS.B        $03
Compt:      DS.B        $01
Seuil:      EQU         $55        

;************************************************************************* 
;************************************************************************* 
;*                                                                       * 
;* D�but du code dans la section CODE SECTION                            * 
;*                                                                       * 
;*                                                                       * 
;*                                                                       * 
;************************************************************************* 
;*************************************************************************

            ORG         ROMStart
            
Lab1b:
            CLI                         ; permettre les interruptions
            
            LDS         #$1000          ; initialisation de la pileau haut
                                        ; de la RAM ($0800-$0FFF)
            MOVB        #$03,Compt      ; Met le compteur � 3

            LDX         #$91
            LDY         #$0800
            
Copie:      LDAA        2,X+
            STAA        1,Y+
            DEC         Compt
            BNE         Copie
            
            LDX         #$0800
Verif:      STAA        1,X+
            STAB        Seuil
            CBA
            BHI         Verif
            
            MOVB        #$05,Compt
            LDD         #0
somme:      INCB
            ABA
            DEC         Compt
            BNE         somme
            
Fin:        BRA         Fin                                         
                                        
;************************************************************************* 
;* 																		 *									  
;* Init du SCI (transmetteur et r�cepteur de caract�res s�riel)			 *
;*	                                                            		 *
;*************************************************************************

            CLR         SCIBDH
            LDAB        #$34            ; si bus clk est � 8MHz
            STAB        SCIBDL          ; 9600 BAUDS
            CLR         SCICR1          ; M BIT = 0 POUR 8 BITS
            LDAB        #$0C
            STAB        SCICR2          ; TE , RE
                                  
            NOLIST
            
;*************************************************************************            
;*																		 *
;* Inclusion du fichier D_BUG12M.ASM									 *
;*																		 *
;*************************************************************************

            INCLUDE 'D_BUG12M.ASM'      ; Fichier pour la simulation des
                                        ; fonctions D_BUG12
                                        
            LIST
            
;*************************************************************************            
;*																		 *
;* Vecteur d'interruption pour le reset									 *
;*																		 *
;*************************************************************************            

            ORG     $FFFE
            fdb     Lab1b               ; Reset
            
            END                         ; Fin de la compilation