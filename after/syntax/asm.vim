" Vim syntax file
" Language:	MIPS Assembler Language
" Maintainer:	ShadowStar <orphen.leiliu@gmail.com>
" Last Change:	2012 Nov 19
" Vim URL:	http://www.vim.org/lang.html
" MIPS_ASM Version: 1.0

"syn case ignore
setlocal iskeyword=a-z,A-Z,48-57,.,_,$
setlocal isident=a-z,A-Z,48-57,.,_

syn keyword asmRegister	r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15
syn keyword asmRegister	r16 r17 r18 r19 r20 r21 r22 r23 r24 r25 r26 r27 r28 r29
syn keyword asmRegister	r30 r31 zero at v0 v1 a0 a1 a2 a3 t0 t1 t2 t3 t4 t5 t6
syn keyword asmRegister	t7 s0 s1 s2 s3 s4 s5 s6 s7 t8 t9 k0 k1 gp sp fp s8 ra
syn keyword asmRegister	$0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15
syn keyword asmRegister	$16 $17 $18 $19 $20 $21 $22 $23 $24 $25 $26 $27 $28 $29
syn keyword asmRegister	$30 $31 hi lo pc

syn keyword asmType	.byte .half .word .dword .float .double .ascii .asciiz
syn keyword asmType	.string .space

syn keyword asmInstr	abs.fmt add add.fmt addi addiu addu alnv.ps and andi b
syn keyword asmInstr	bal bc1f bc1fl bc1t bc1tl bc2f bc2fl bc2t bc2tl beq beql
syn keyword asmInstr	bgez bgezal bgezall bgezl bgtz bgtzl blez blezl bltz
syn keyword asmInstr	bltzal bltzall bltzl bne bnel break c.cond.fmt cache
syn keyword asmInstr	ceil.l.fmt ceil.w.fmt cfc1 cfc2 clo cop2 clz ctc1 ctc2
syn keyword asmInstr	cvt.d.fmt cvt.l.fmt cvt.ps.s cvt.s.fmt cvt.s.pl cvt.s.pu
syn keyword asmInstr	cvt.w.fmt dadd daddi daddiu daddu dclo dclz ddiv ddivu
syn keyword asmInstr	deret dext dextm dextu di dins dinsm dinsu div div.fmt
syn keyword asmInstr	divu dmfc0 dmfc1 dmfc2 dmtc0 dmtc1 dmtc2 dmult dmultu
syn keyword asmInstr	drotr drotr32 drotrv dsbh dshd dsll dsll32 dsllv dsra
syn keyword asmInstr	dsra32 dsrav dsrl dsrl32 dsrlv dsub dsubu ehb ei eret
syn keyword asmInstr	ext floor.l.fmt floor.w.fmt ins j jal jalr jalr.hb jalx
syn keyword asmInstr	jr jr.hb lb lbu ld ldc1 ldc2 ldl ldr ldxc1 lh lhu ll lld
syn keyword asmInstr	lui luxc1 lw lwc1 lwc2 lwl lwr lwu lwxc1 madd madd.fmt
syn keyword asmInstr	maddu mfc0 mfc1 mfc2 mfhc1 mfhc2 mfhi mflo mov.fmt movf
syn keyword asmInstr	movf.fmt movn movn.fmt movt movt.fmt movz movz.fmt msub
syn keyword asmInstr	msub.fmt msubu mtc0 mtc1 mtc2 mthc1 mthc2 mthi mtlo mul
syn keyword asmInstr	mul.fmt mult multu neg.fmt nmadd.fmt nmsub.fmt nop nor
syn keyword asmInstr	or ori pause pll.ps plu.ps pref prefx pul.ps puu.ps
syn keyword asmInstr	rdhwr rdpgpr recip.fmt rotr rotrv round.l.fmt
syn keyword asmInstr	round.w.fmt rsqrt.fmt sb sc scd sd sdbbp sdc1 sdc2 sdl
syn keyword asmInstr	sdr sdxc1 seb seh sh sll sllv slt slti sltiu sltu
syn keyword asmInstr	sqrt.fmt sra srav srl srlv ssnop sub sub.fmt subu suxc1
syn keyword asmInstr	sw swc1 swc2 swl swr swxc1 sync synci syscall teq teqi
syn keyword asmInstr	tge tgei tgeiu tgeu tlbp tlbr tlbwi tlbwr tlt tlti tltiu
syn keyword asmInstr	tltu tne tnei trunc.l.fmt trunc.w.fmt wait wrpgpr wsbh
syn keyword asmInstr	xor xori

syn keyword asmCvmx	baddu dmul exts exts32 cins cins32 mtm0 mtm1 mtm2 mtp0
syn keyword asmCvmx	mtp1 mtp2 v3mulu vmm0 vmulu dpop pop seq seqi sne snei
syn keyword asmCvmx	bbit0 bbit32 bbit1 bbit132 pref4 pref5 pref28 pref29
syn keyword asmCvmx	pref30 saa saad synciobdma syncs syncw syncws uld ulw
syn keyword asmCvmx	usd usw rdhwr30 rdhwr31 cvm_mf_crc_iv
syn keyword asmCvmx	cvm_mf_crc_iv_reflect cvm_mf_crc_len
syn keyword asmCvmx	cvm_mf_crc_polynomial cvm_mt_crc_byte
syn keyword asmCvmx	cvm_mt_crc_byte_reflect cvm_mt_crc_dword
syn keyword asmCvmx	cvm_mt_crc_dword_reflect cvm_mt_crc_half
syn keyword asmCvmx	cvm_mt_crc_half_reflect cvm_mt_crc_iv
syn keyword asmCvmx	cvm_mt_crc_iv_reflect cvm_mt_crc_len
syn keyword asmCvmx	cvm_mt_crc_polynomial cvm_mt_crc_polynomial_reflect
syn keyword asmCvmx	cvm_mt_crc_var cvm_mt_crc_var_reflect cvm_mt_crc_word
syn keyword asmCvmx	cvm_mt_crc_word_reflect cvm_mf_3des_iv cvm_mf_3des_key
syn keyword asmCvmx	cvm_mf_3des_result cvm_mt_3des_dec cvm_mt_3des_dec_cbc
syn keyword asmCvmx	cvm_mt_3des_enc cvm_mt_3des_enc_cbc cvm_mt_3des_iv
syn keyword asmCvmx	cvm_mt_3des_key cvm_mt_3des_result cvm_mf_aes_inp0
syn keyword asmCvmx	cvm_mf_aes_iv cvm_mf_aes_key cvm_mf_aes_keylength
syn keyword asmCvmx	cvm_mf_aes_resinp cvm_mt_aes_dec_cbc0
syn keyword asmCvmx	cvm_mt_aes_dec_cbc1 cvm_mt_aes_dec0 cvm_mt_aes_dec1
syn keyword asmCvmx	cvm_mt_aes_enc_cbc0 cvm_mt_aes_enc_cbc1 cvm_mt_aes_enc0
syn keyword asmCvmx	cvm_mt_aes_enc1 cvm_mt_aes_iv cvm_mt_aes_key
syn keyword asmCvmx	cvm_mt_aes_keylength cvm_mt_aes_resinp cvm_mf_gfm_mul
syn keyword asmCvmx	cvm_mf_gfm_poly cvm_mf_gfm_resinp cvm_mt_gfm_mul
syn keyword asmCvmx	cvm_mt_gfm_poly cvm_mt_gfm_resinp cvm_mt_gfm_xor0
syn keyword asmCvmx	cvm_mt_gfm_xormul1 cvm_mf_hsh_dat cvm_mf_hsh_datw
syn keyword asmCvmx	cvm_mf_hsh_iv cvm_mf_hsh_ivw cvm_mt_hsh_dat
syn keyword asmCvmx	cvm_mt_hsh_datw cvm_mt_hsh_iv cvm_mt_hsh_ivw
syn keyword asmCvmx	cvm_mt_hsh_startmd5 cvm_mt_hsh_startsha
syn keyword asmCvmx	cvm_mt_hsh_startsha256 cvm_mt_hsh_startsha512
syn keyword asmCvmx	cvm_mf_kas_key cvm_mf_kas_result cvm_mt_kas_key
syn keyword asmCvmx	cvm_mt_kas_result cvm_mt_kas_enc cvm_mt_kas_enc_cbc

syn keyword asmCvmx2	qmac.00 qmac.01 qmac.02 qmac.03 qmacs.00 qmacs.01
syn keyword asmCvmx2	qmacs.02 qmacs.03 pref25 pref26 pref27 pref31 lbx lbux
syn keyword asmCvmx2	lhx lhux lwx lwux ldx laa laad law lawd lai laid lad
syn keyword asmCvmx2	ladd las lasd lac lacd zcb zcbt
syn keyword asmCvmx2	cvm_mf_gfm_resinp_reflect cvm_mt_gfm_mul_reflect
syn keyword asmCvmx2	cvm_mt_gfm_xor0_reflect cvm_mt_gfm_xormul1_reflect
syn keyword asmCvmx2	cvm_mf_snow3g_lfsr cvm_mf_snow3g_fsm
syn keyword asmCvmx2	cvm_mf_snow3g_result cvm_mt_snow3g_lfsr
syn keyword asmCvmx2	cvm_mt_snow3g_fsm cvm_mt_snow3g_result
syn keyword asmCvmx2	cvm_mt_snow3g_start cvm_mt_snow3g_more
syn keyword asmCvmx2	cvm_mf_sms4_iv cvm_mf_sms4_key cvm_mf_sms4_resinp
syn keyword asmCvmx2	cvm_mt_sms4_dec_cbc0 cvm_mt_sms4_dec_cbc1
syn keyword asmCvmx2	cvm_mt_sms4_dec0 cvm_mt_sms4_dec1 cvm_mt_sms4_enc_cbc0
syn keyword asmCvmx2	cvm_mt_sms4_enc_cbc1 cvm_mt_sms4_enc0 cvm_mt_sms4_enc1
syn keyword asmCvmx2	cvm_mt_sms4_iv cvm_mt_sms4_key cvm_mt_sms4_resnip

syn keyword asmPseudo	li move dli la dla negu not beqz bnez blt bge bgt

syn match   asmOperator	"[+-/*]"

syn match   asmBinNum	"\<[0-1]\+b\>"
syn match   asmHexNum	"\<\d\x*h\>"
syn match   asmHexNum	"\<\(0x\|$\)\x*\>"
syn match   asmFPUNum	"\<\d\+\(\.\d*\)\=\(e[-+]\=\d*\)\=\>"
syn match   asmOctNum	"\<\(0\o\+o\=\|\o\+o\)\>"
syn match   asmDecNum	"\<\(0\|[1-9]\+\)\>"
syn match   asmNumError	"\<\~\s*\d\+\.\d*\(e[+-]\=\d\+\)\=\>"

syn region  asmComment	start="\/\/" end="$" contains=asmTodo
syn region  asmComment	start="\/\*" end="\*\/" contains=asmTodo

syn match   asmStrError	+["']+
syn match   asmString	+\("[^"]\{-}"\|'[^']\{-}'\)+

syn match   asmLabel	"^\s*[^; \t]\+:"
syn match   asmFunction	"\<\h\w*\>\(\s\|\n\)*("me=e-1
syn region  asmMacro	start="^\s*\(%:\|#\)\s*\(define\|undef\|ifdef\|endif\|else\|ifndef\|if\)\>" skip="\\$" end="$" contains=ALLBUT,asmComment,asmIdentifier,@origNumber

syn region  asmIncluded	start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match   asmIncluded	"<[^>]*>"
syn match   asmInclude	"^\s*\(%:\|#\)\s*include\>\s*["<]" contains=asmIncluded

syn cluster origNumber	contains=binNumber,hexNumber,octNumber,decNumber

hi def link asmNumError	Error
hi def link asmStrError	Error
hi def link asmInstr	Keyword
hi def link asmCvmx	Keyword
hi def link asmCvmx2	Keyword
hi def link asmPseudo	Function
hi def link asmRegister	Type
hi def link asmOperator	Operator
hi def link asmBinNum	Number
hi def link asmHexNum	Number
hi def link asmFPUNum	Number
hi def link asmOctNum	Number
hi def link asmDecNum	Number
hi def link asmString	String
hi def link asmMacro	Macro
hi def link asmFunction	Macro
hi def link asmInclude	Include
hi def link asmIncluded	String
" vim: ts=8 sw=8 :
