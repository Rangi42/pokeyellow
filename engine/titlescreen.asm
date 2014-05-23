; copy text of fixed length $b (like player name, rival name, mon names, ...)
CopyFixedLengthText: ; 42b1 (1:42b1)
	ld bc, $b
	jp CopyData

SetDefaultNamesBeforeTitlescreen: ; 42b7 (1:42b7)
	ld hl, NintenText
	ld de, W_PLAYERNAME ; $d158
	call CopyFixedLengthText
	ld hl, SonyText
	ld de, W_RIVALNAME ; $d34a
	call CopyFixedLengthText
	xor a
	ld [$ffb0], a
	ld [$d358], a
	ld hl, $d732
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, Bank(Func_7d8ea)
	ld [$c0ef], a
	ld [$c0f0], a

LoadTitlescreenGraphics: ; 42dd (1:42dd)
	call GBPalWhiteOut
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a ; $ffba
	xor a
	ld [$ffd7], a
	ld [$ffae], a
	ld a, $40
	ld [$ffaf], a
	ld a, $90
	ld [$ffb0], a
	call ClearScreen
	call DisableLCD
	call LoadFontTilePatterns
	ld hl, NintendoCopyrightLogoGraphics ; $60c8
	ld de, $9410
	ld bc, $50
	ld a, BANK(NintendoCopyrightLogoGraphics)
	call FarCopyData2
	ld hl, GamefreakLogoGraphics ; $61f8
	ld de, $9460
	ld bc, $90
	ld a, BANK(GamefreakLogoGraphics)
	call FarCopyData2
	ld hl, PokemonLogoGraphics ; $5380
	ld de, $8800
	ld bc, $600
	ld a, BANK(PokemonLogoGraphics)
	call FarCopyData2          ; first chunk
	ld hl, PokemonLogoGraphics+$600 ; $5980
	ld de, $9310
	ld bc, $100
	ld a, BANK(PokemonLogoGraphics)
	call FarCopyData2          ; second chunk
	ld hl, Version_GFX ; $402f
IF _RED
	ld de,$9600 ; where to put redgreenversion.2bpp in the VRAM
	ld bc,$50 ; how big that file is
ENDC
IF _BLUE
	ld de,$9610 ; where to put blueversion.2bpp in the VRAM
	ld bc,$40 ; how big that file is
ENDC

	ld a, BANK(Version_GFX)
	call FarCopyDataDouble
	call Func_4519
	FuncCoord 2, 1 ; $c3b6
	ld hl, Coord
	ld a, $80
	ld de, $14
	ld c, $6
.asm_434d
	ld b, $10
	push hl
.asm_4350
	ld [hli], a
	inc a
	dec b
	jr nz, .asm_4350
	pop hl
	add hl, de
	dec c
	jr nz, .asm_434d
	FuncCoord 2, 7 ; $c42e
	ld hl, Coord
	ld a, $31
	ld b, $10
.asm_4361
	ld [hli], a
	inc a
	dec b
	jr nz, .asm_4361
	call Func_44dd
	ld hl, $c328
	ld a, $74
	ld [hl], a
	FuncCoord 2, 17 ; $c4f6
	ld hl, Coord
	ld de, .titlescreenTilemap ; $437f
	ld b, $10
.asm_4377
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .asm_4377
	jr .asm_438f

.titlescreenTilemap ; 437f (1:437f)
	db $41,$42,$43,$42,$44,$42,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E ; ©'95.'96.'98 GAME FREAK inc.

.asm_438f
	call SaveScreenTilesToBuffer2
	call LoadScreenTilesFromBuffer2
	call EnableLCD
IF _RED
	ld a,CHARMANDER ; which Pokemon to show first on the title screen
ENDC
IF _BLUE
	ld a,SQUIRTLE ; which Pokemon to show first on the title screen
ENDC

	ld [wWhichTrade], a ; $cd3d
	call Func_4524
	ld a, $9b
	call Func_4533
	call SaveScreenTilesToBuffer1
	ld a, $40
	ld [$ffb0], a
	call LoadScreenTilesFromBuffer2
	ld a, $98
	call Func_4533
	ld b, $6
	call GoPAL_SET
	call GBPalNormal
	ld a, $e4
	ld [rOBP0], a ; $ff48
	ld bc, $ffaf ; background scroll Y
	ld hl, .TitleScreenPokemonLogoYScrolls ; $43db
.asm_43c6
	ld a, [hli]
	and a
	jr z, .asm_43f4
	ld d, a
	cp $fd
	jr nz, .asm_43d4
	ld a, (SFX_1f_62 - SFX_Headers_1f) / 3
	call PlaySound
.asm_43d4
	ld a, [hli]
	ld e, a
	call .ScrollTitleScreenPokemonLogo
	jr .asm_43c6

.TitleScreenPokemonLogoYScrolls: ; 43db (1:43db)
; Controls the bouncing effect of the Pokemon logo on the title screen
	db -4,16  ; y scroll amount, number of times to scroll
	db 3,4
	db -3,4
	db 2,2
	db -2,2
	db 1,2
	db -1,2
	db 0      ; terminate list with 0

.ScrollTitleScreenPokemonLogo
; Scrolls the Pokemon logo on the title screen to create the bouncing effect
; Scrolls d pixels e times
	call DelayFrame
	ld a, [bc]
	add d
	ld [bc], a
	dec e
	jr nz, .ScrollTitleScreenPokemonLogo
	ret
.asm_43f4
	call LoadScreenTilesFromBuffer1
	ld c, $24
	call DelayFrames
	ld a, (SFX_1f_63 - SFX_Headers_1f) / 3
	call PlaySound
	call PrintGameVersionOnTitleScreen
	ld a, $90
	ld [$ffb0], a
	ld d, $90
.asm_440a
	ld h, d
	ld l, $40
	call Func_44cf
	ld h, $0
	ld l, $50
	call Func_44cf
	ld a, d
	add $4
	ld d, a
	and a
	jr nz, .asm_440a
	ld a, $9c
	call Func_4533
	call LoadScreenTilesFromBuffer2
	call PrintGameVersionOnTitleScreen
	call Delay3
	call WaitForSoundToFinish
	ld a, MUSIC_TITLE_SCREEN
	ld [$c0ee], a
	call PlaySound
	xor a
	ld [$cc5b], a
.asm_443b
	ld c, $c8
	call CheckForUserInterruption
	jr c, .asm_4459
	call Func_44c1
	ld c, $1
	call CheckForUserInterruption
	jr c, .asm_4459
	callba Func_372ac
	call Func_4496
	jr .asm_443b
.asm_4459
	ld a, [wWhichTrade] ; $cd3d
	call PlayCry
	call WaitForSoundToFinish
	call GBPalWhiteOutWithDelay3
	call CleanLCD_OAM
	xor a
	ld [$ffb0], a
	inc a
	ld [H_AUTOBGTRANSFERENABLED], a ; $ffba
	call ClearScreen
	ld a, $98
	call Func_4533
	ld a, $9c
	call Func_4533
	call Delay3
	call LoadGBPal
	ld a, [H_CURRENTPRESSEDBUTTONS]
	ld b, a
	and $46
	cp $46
	jp z, Func_448e
	jp MainMenu

Func_448e: ; 448e (1:448e)
	ld b, BANK(Func_1c98a)
	ld hl, Func_1c98a
	jp Bankswitch

Func_4496: ; 4496 (1:4496)
	ld a, $98
	call Func_4533

.new
; Generate a new TitleMon.
	call GenRandom
	and $f
	ld c, a
	ld b, 0
	ld hl, TitleMons
	add hl, bc
	ld a, [hl]
	ld hl, wWhichTrade ; $cd3d

; Can't be the same as before.
	cp [hl]
	jr z, .new

	ld [hl], a
	call Func_4524

	ld a, $90
	ld [$ffb0], a
	ld d, 1 ; scroll out
	callba TitleScroll ; indirect jump to TitleScroll (37258 (d:7258))
	ret

Func_44c1: ; 44c1 (1:44c1)
	ld d, 0 ; scroll in
	callba TitleScroll ; indirect jump to TitleScroll (37258 (d:7258))
	xor a
	ld [$ffb0], a
	ret

Func_44cf: ; 44cf (1:44cf)
.wait
	ld a, [$ff44] ; rLY
	cp l
	jr nz, .wait

	ld a, h
	ld [rSCX], a ; $ff43

.wait2
	ld a, [$ff44] ; rLY
	cp h
	jr z, .wait2
	ret

Func_44dd: ; 44dd (1:44dd)
	ld hl, PlayerCharacterTitleGraphics ; $66a8
	ld de, $8000
	ld bc, $230
	ld a, BANK(PlayerCharacterTitleGraphics)
	call FarCopyData2
	call CleanLCD_OAM
	xor a
	ld [wWhichTrade], a ; $cd3d
	ld hl, wOAMBuffer
	ld de, $605a
	ld b, $7
.asm_44fa
	push de
	ld c, $5
.asm_44fd
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a
	add $8
	ld e, a
	ld a, [wWhichTrade] ; $cd3d
	ld [hli], a
	inc a
	ld [wWhichTrade], a ; $cd3d
	inc hl
	dec c
	jr nz, .asm_44fd
	pop de
	ld a, $8
	add d
	ld d, a
	dec b
	jr nz, .asm_44fa
	ret

Func_4519: ; 4519 (1:4519)
	ld hl, $9800
	ld bc, $800
	ld a, $7f
	jp FillMemory

Func_4524: ; 4524 (1:4524)
	ld [$cf91], a
	ld [$d0b5], a
	FuncCoord 5, 10 ; $c46d
	ld hl, Coord
	call GetMonHeader
	jp LoadFrontSpriteByMonIndex

Func_4533: ; 4533 (1:4533)
	ld [$ffbd], a
	jp Delay3

LoadCopyrightAndTextBoxTiles: ; 4538 (1:4538)
	xor a
	ld [$ffb0], a
	call ClearScreen
	call LoadTextBoxTilePatterns

LoadCopyrightTiles: ; 4541 (1:4541)
	ld de, NintendoCopyrightLogoGraphics ; $60c8
	ld hl, $9600
	ld bc, (BANK(NintendoCopyrightLogoGraphics) << 8) + $1c
	call CopyVideoData
	FuncCoord 2, 7 ; $c42e
	ld hl, Coord
	ld de, CopyrightTextString ; $4556
	jp PlaceString

CopyrightTextString: ; 4556 (1:4556)
	db   $60,$61,$62,$61,$63,$61,$64,$7F,$65,$66,$67,$68,$69,$6A             ; ©'95.'96.'98 Nintendo
	next $60,$61,$62,$61,$63,$61,$64,$7F,$6B,$6C,$6D,$6E,$6F,$70,$71,$72     ; ©'95.'96.'98 Creatures inc.
	next $60,$61,$62,$61,$63,$61,$64,$7F,$73,$74,$75,$76,$77,$78,$79,$7A,$7B ; ©'95.'96.'98 GAME FREAK inc.
	db   "@"

INCLUDE "data/title_mons.asm"

; prints version text (red, blue)
PrintGameVersionOnTitleScreen: ; 4598 (1:4598)
	FuncCoord 7, 8 ; $c447
	ld hl, Coord
	ld de, VersionOnTitleScreenText
	jp PlaceString

; these point to special tiles specifically loaded for that purpose and are not usual text
VersionOnTitleScreenText: ; 45a1 (1:45a1)
IF _RED
	db $60,$61,$7F,$65,$66,$67,$68,$69,"@" ; "Red Version"
ENDC
IF _BLUE
	db $61,$62,$63,$64,$65,$66,$67,$68,"@" ; "Blue Version"
ENDC