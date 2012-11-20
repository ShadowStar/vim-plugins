" Vim syntax file
" Language: MIPS
" Maintainer:   Alex Brick <alex@alexrbrick.com>
" Last Change:  2007 Oct 18

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

setlocal iskeyword+=-,$
syntax case match

syntax keyword	mipsTodo	contained TODO
syntax match	mipsComment	"#.*"
syntax match	mipsComment	"\/\/.*"
syntax region	mipsComment	start="\/\*" end="\*\/"
syntax match	mipsNumber	"\<\(0\|-\?[1-9]\d*\)\>" " Dec numbers
syntax match	mipsNumber	"\<0[0-7]\+\>" " Oct numbers
syntax match	mipsNumber	"\<0x[0-9a-fA-F]\+\>" " Hex numbers
syntax region	mipsString	start=+"+ end=+"+ skip=+\\"+
syntax match	mipsLabelColon	":" contained
syntax match	mipsLabel	"\w\+:" contains=mipsLabelColon
syntax match	mipsFunction	"\<\h\w*\>\(\s\|\n\)*("me=e-1
syntax match	mipsIdentifier	"\<[a-z_][a-z0-9_]*\>"
syntax match	mipsMacro	"\<[A-Z_][A-Z0-9_]*\>" contains=mipsFunction
syntax region	mipsIncluded	start=+"+ skip=+\\\\\|\\"+ end=+"+
syntax match	mipsIncluded	"<[^>]*>"
syntax match	mipsInclude	"^\s*#\s*include\>\s*["<]" contains=mipsIncluded
syntax region	mipsDefine	start="^\s*#\s*\(define\|undef\|ifdef\|endif\|else\|ifndef\|if\)\>" skip="\\$" end="$" contains=ALLBUT,mipsComment,mipsIdentifier

" Registers
syntax match	mipsRegister	"\<\$\?pc\>"
syntax match	mipsRegister	"\<\$\?hi\>"
syntax match	mipsRegister	"\<\$\?lo\>"
syntax match	mipsRegister	"\<\$\?zero\>"
syntax match	mipsRegister	"\<\$\?at\>"
syntax match	mipsRegister	"\<\$\?v0\>"
syntax match	mipsRegister	"\<\$\?v1\>"
syntax match	mipsRegister	"\<\$\?a0\>"
syntax match	mipsRegister	"\<\$\?a1\>"
syntax match	mipsRegister	"\<\$\?a2\>"
syntax match	mipsRegister	"\<\$\?a3\>"
syntax match	mipsRegister	"\<\$\?t0\>"
syntax match	mipsRegister	"\<\$\?t1\>"
syntax match	mipsRegister	"\<\$\?t2\>"
syntax match	mipsRegister	"\<\$\?t3\>"
syntax match	mipsRegister	"\<\$\?t4\>"
syntax match	mipsRegister	"\<\$\?t5\>"
syntax match	mipsRegister	"\<\$\?t6\>"
syntax match	mipsRegister	"\<\$\?t7\>"
syntax match	mipsRegister	"\<\$\?t8\>"
syntax match	mipsRegister	"\<\$\?t9\>"
syntax match	mipsRegister	"\<\$\?s0\>"
syntax match	mipsRegister	"\<\$\?s1\>"
syntax match	mipsRegister	"\<\$\?s2\>"
syntax match	mipsRegister	"\<\$\?s3\>"
syntax match	mipsRegister	"\<\$\?s4\>"
syntax match	mipsRegister	"\<\$\?s5\>"
syntax match	mipsRegister	"\<\$\?s6\>"
syntax match	mipsRegister	"\<\$\?s7\>"
syntax match	mipsRegister	"\<\$\?k0\>"
syntax match	mipsRegister	"\<\$\?k1\>"
syntax match	mipsRegister	"\<\$\?gp\>"
syntax match	mipsRegister	"\<\$\?sp\>"
syntax match	mipsRegister	"\<\$\?fp\>"
syntax match	mipsRegister	"\<\$\?ra\>"
syntax match	mipsRegister	"\<\$\?fir\>"
syntax match	mipsRegister	"\<\$\?fccr\>"
syntax match	mipsRegister	"\<\$\?fexr\>"
syntax match	mipsRegister	"\<\$\?fenr\>"
syntax match	mipsRegister	"\<\$\?fcsr\>"
syntax match	mipsRegister	"\<\$\?fcr0\>"
syntax match	mipsRegister	"\<\$\?fcr25\>"
syntax match	mipsRegister	"\<\$\?fcr26\>"
syntax match	mipsRegister	"\<\$\?fcr28\>"

let i = 0
while i < 32
    " This is for the regular registers
    execute 'syntax match mipsRegister "\<\$' . i . '\>"'
    execute 'syntax match mipsRegister "\<r' . i . '\>"'
    " And this is for the FPU registers
    execute 'syntax match mipsRegister "\<\$\?f' . i . '\>"'
    let i += 1
endwhile

" Directives
syntax match	mipsDirective	"\<\.2byte\>"
syntax match	mipsDirective	"\<\.4byte\>"
syntax match	mipsDirective	"\<\.8byte\>"
syntax match	mipsDirective	"\<\.aent\>"
syntax match	mipsDirective	"\<\.align\>"
syntax match	mipsDirective	"\<\.aascii\>"
syntax match	mipsDirective	"\<\.ascii\>"
syntax match	mipsDirective	"\<\.asciiz\>"
syntax match	mipsDirective	"\<\.byte\>"
syntax match	mipsDirective	"\<\.comm\>"
syntax match	mipsDirective	"\<\.cpadd\>"
syntax match	mipsDirective	"\<\.cpload\>"
syntax match	mipsDirective	"\<\.cplocal\>"
syntax match	mipsDirective	"\<\.cprestore\>"
syntax match	mipsDirective	"\<\.cpreturn\>"
syntax match	mipsDirective	"\<\.cpsetup\>"
syntax match	mipsDirective	"\<\.data\>"
syntax match	mipsDirective	"\<\.double\>"
syntax match	mipsDirective	"\<\.dword\>"
syntax match	mipsDirective	"\<\.dynsym\>"
syntax match	mipsDirective	"\<\.end\>"
syntax match	mipsDirective	"\<\.endr\>"
syntax match	mipsDirective	"\<\.ent\>"
syntax match	mipsDirective	"\<\.extern\>"
syntax match	mipsDirective	"\<\.file\>"
syntax match	mipsDirective	"\<\.float\>"
syntax match	mipsDirective	"\<\.fmask\>"
syntax match	mipsDirective	"\<\.frame\>"
syntax match	mipsDirective	"\<\.globl\>"
syntax match	mipsDirective	"\<\.gpvalue\>"
syntax match	mipsDirective	"\<\.gpword\>"
syntax match	mipsDirective	"\<\.half\>"
syntax match	mipsDirective	"\<\.irp\>"
syntax match	mipsDirective	"\<\.kdata\>"
syntax match	mipsDirective	"\<\.ktext\>"
syntax match	mipsDirective	"\<\.lab\>"
syntax match	mipsDirective	"\<\.lcomm\>"
syntax match	mipsDirective	"\<\.loc\>"
syntax match	mipsDirective	"\<\.mask\>"
syntax match	mipsDirective	"\<\.nada\>"
syntax match	mipsDirective	"\<\.nop\>"
syntax match	mipsDirective	"\<\.option\>"
syntax match	mipsDirective	"\<\.origin\>"
syntax match	mipsDirective	"\<\.repeat\>"
syntax match	mipsDirective	"\<\.rdata\>"
syntax match	mipsDirective	"\<\.sdata\>"
syntax match	mipsDirective	"\<\.section\>"
syntax match	mipsDirective	"\<\.set\>"
syntax match	mipsDirective	"\<\.size\>"
syntax match	mipsDirective	"\<\.space\>"
syntax match	mipsDirective	"\<\.string\>"
syntax match	mipsDirective	"\<\.struct\>"
syntax match	mipsDirective	"\<\.text\>"
syntax match	mipsDirective	"\<\.type\>"
syntax match	mipsDirective	"\<\.verstamp\>"
syntax match	mipsDirective	"\<\.weakext\>"
syntax match	mipsDirective	"\<\.word\>"

" Arithmetic Instructions
syntax keyword	mipsInstruction	add addi addiu addu clo clz dadd daddi daddiu
syntax keyword	mipsInstruction	daddu dclo dclz ddiv ddivu div divu dmult dmultu
syntax keyword	mipsInstruction	dsub dsubu madd maddu msub msubu mul mult multu
syntax keyword	mipsInstruction	seb seh slt slti sltiu sltu sub subu

" Branch and Jump Instructions
syntax keyword	mipsInstruction	b bal beq bgez bgezal bgtz blez bltz bltzal bne
syntax keyword	mipsInstruction	j jal jalr jalx jr
syntax match	mipsInstruction	"\<jalr\.hb"
syntax match	mipsInstruction	"\<jr\.hb"

" Instruction Control Instructions
syntax keyword	mipsInstruction	ehb nop pause ssnop

" Load, Store and Memory Control Instructions
syntax keyword	mipsInstruction	lb lbu ld ldl ldr lh lhu ll lld lw lwl lwr lwu
syntax keyword	mipsInstruction	pref sb sc scd sd sdl sdr sh sw swl swr sync
syntax keyword	mipsInstruction	synci

" Logical Instructions
syntax keyword	mipsInstruction	and andi lui nor or ori xor xori

" Insert/Extract Instructions
syntax keyword	mipsInstruction	dext dextm dextu dins dinsm dinsu dsbh dshd ext
syntax keyword	mipsInstruction	ins wsbh

" Move Instructions
syntax keyword	mipsInstruction	mfhi mflo movf movn movt movz mthi mtlo rdhwr

" Shift Instructions
syntax keyword	mipsInstruction	drotr drotr32 drotrv dsll dsll32 dsllv dsra
syntax keyword	mipsInstruction	dsra32 dsrav dsrl dsrl32 dsrlv rotr rotrv sll
syntax keyword	mipsInstruction	sllv sra srav srl srlv

" Trap Instructions
syntax keyword	mipsInstruction	break syscall teq teqi tge tgei tgeiu tgeu tlt
syntax keyword	mipsInstruction	tlti tltiu tltu tne tnei

" Obsolete Branch Instructions
syntax keyword	mipsInstruction beql bgezall bgezl bgtzl blezl bltzall bltzl
syntax keyword	mipsInstruction	bnel

" FPU Arithmetic Instructions
syntax match	mipsInstruction	"\<abs\.\(s\|d\|ps\)\>"
syntax match	mipsInstruction	"\<add\.\(s\|d\|ps\)\>"
syntax match	mipsInstruction	"\<div\.[sd]\>"
syntax match	mipsInstruction	"\<madd\.\(s\|d\|ps\)\>"
syntax match	mipsInstruction	"\<msub\.\(s\|d\|ps\)\>"
syntax match	mipsInstruction	"\<mul\.\(s\|d\|ps\)\>"
syntax match	mipsInstruction	"\<neg\.\(s\|d\|ps\)\>"
syntax match	mipsInstruction	"\<nmadd\.\(s\|d\|ps\)\>"
syntax match	mipsInstruction	"\<nmsub\.\(s\|d\|ps\)\>"
syntax match	mipsInstruction	"\<recip\.[sd]\>"
syntax match	mipsInstruction	"\<rsqrt\.[sd]\>"
syntax match	mipsInstruction	"\<sqrt\.[sd]\>"
syntax match	mipsInstruction	"\<sub\.\(s\|d\|ps\)\>"

" FPU Branch Instructions
syntax keyword	mipsInstruction	bc1f bc1t

" FPU Compare Instructions
syntax match	mipsInstruction	"\<c\.\(s\?[ft]\|un\|or\|[nsu]\?eq\|[no]\?gl\|[nou]\?lt\|[nou]\?uge\|[gnou]\?le\|[nou]\?gt\|ngle\|sne\)\.\(s\|d\|ps\)\>"

" FPU Convert Instructions
syntax match	mipsInstruction	"\<alnv\.ps\>"
syntax match	mipsInstruction	"\<ceil\.[lw]\.[ds]\>"
syntax match	mipsInstruction	"\<cvt\.[lw]\.[sd]\>"
syntax match	mipsInstruction	"\<cvt\.d\.[swl]\>"
syntax match	mipsInstruction	"\<cvt\.s\.[dwl]\>"
syntax match	mipsInstruction	"\<cvt\.s\.p[ul]\>"
syntax match	mipsInstruction	"\<cvt\.ps\.s\>"
syntax match	mipsInstruction	"\<floor\.[lw]\.[sd]\>"
syntax match	mipsInstruction	"\<pl[lu]\.ps\>"
syntax match	mipsInstruction	"\<pu[lu]\.ps\>"
syntax match	mipsInstruction	"\<round\.[lw]\.[sd]\>"
syntax match	mipsInstruction	"\<trunc\.[lw]\.[sd]\>"

" FPU Load, Store and Memory Control Instructions
syntax keyword	mipsInstruction	ldc1 ldxc1 luxc1 lwc1 lwxc1 prefx sdc1 sdxc1
syntax keyword	mipsInstruction	suxc1 swc1 swxc1

" FPU Move Instructions
syntax keyword	mipsInstruction	cfc1 ctc1 dmfc1 dmtc1 mfc1 mfhc1 mtc1 mthc1
syntax match	mipsInstruction	"\<mov[fntz]\?\.\(s\|d\|ps\)\>"

" Obsolete FPU Branch Instructions
syntax keyword	mipsInstruction	bc1fl bc1tl

" Coprocessor Branch Instructions
syntax keyword	mipsInstruction	bc2f bc2t

" Coprocessor Execute Instructions
syntax keyword	mipsInstruction	cop2

" Coprocessor Load and Store Instructions
syntax keyword	mipsInstruction	ldc2 lwc2 sdc2 swc2

" Coprocessor Move Instructions
syntax keyword	mipsInstruction	cfc2 ctc2 dmfc2 dmtc2 mfc2 mfhc2 mtc2 mthc2

" Obsolete Coprocessor Branch Instructions
syntax keyword	mipsInstruction	bc2fl bc2tl

" Privileged Instructions
syntax keyword	mipsInstruction	cache di dmfc0 dmtc0 ei eret mfc0 mtc0 rdpgpr
syntax keyword	mipsInstruction	tlbp tlbr tlbwi tlbwr wait wrpgpr

" EJTAG Instructions
syntax keyword	mipsInstruction	deret sdbbp

" cnMIPS Instructions
syntax keyword	cvmInstruction	baddu dmul exts exts32 cins cins32 mtm0 mtm1 mtm2 mtp0
syntax keyword	cvmInstruction	mtp1 mtp2 v3mulu vmm0 vmulu dpop pop seq seqi sne snei
syntax keyword	cvmInstruction	bbit0 bbit32 bbit1 bbit132 pref4 pref5 pref28 pref29
syntax keyword	cvmInstruction	pref30 saa saad synciobdma syncs syncw syncws uld ulw
syntax keyword	cvmInstruction	usd usw rdhwr30 rdhwr31 cvm_mf_crc_iv
syntax keyword	cvmInstruction	cvm_mf_crc_iv_reflect cvm_mf_crc_len
syntax keyword	cvmInstruction	cvm_mf_crc_polynomial cvm_mt_crc_byte
syntax keyword	cvmInstruction	cvm_mt_crc_byte_reflect cvm_mt_crc_dword
syntax keyword	cvmInstruction	cvm_mt_crc_dword_reflect cvm_mt_crc_half
syntax keyword	cvmInstruction	cvm_mt_crc_half_reflect cvm_mt_crc_iv
syntax keyword	cvmInstruction	cvm_mt_crc_iv_reflect cvm_mt_crc_len
syntax keyword	cvmInstruction	cvm_mt_crc_polynomial cvm_mt_crc_polynomial_reflect
syntax keyword	cvmInstruction	cvm_mt_crc_var cvm_mt_crc_var_reflect cvm_mt_crc_word
syntax keyword	cvmInstruction	cvm_mt_crc_word_reflect cvm_mf_3des_iv cvm_mf_3des_key
syntax keyword	cvmInstruction	cvm_mf_3des_result cvm_mt_3des_dec cvm_mt_3des_dec_cbc
syntax keyword	cvmInstruction	cvm_mt_3des_enc cvm_mt_3des_enc_cbc cvm_mt_3des_iv
syntax keyword	cvmInstruction	cvm_mt_3des_key cvm_mt_3des_result cvm_mf_aes_inp0
syntax keyword	cvmInstruction	cvm_mf_aes_iv cvm_mf_aes_key cvm_mf_aes_keylength
syntax keyword	cvmInstruction	cvm_mf_aes_resinp cvm_mt_aes_dec_cbc0
syntax keyword	cvmInstruction	cvm_mt_aes_dec_cbc1 cvm_mt_aes_dec0 cvm_mt_aes_dec1
syntax keyword	cvmInstruction	cvm_mt_aes_enc_cbc0 cvm_mt_aes_enc_cbc1 cvm_mt_aes_enc0
syntax keyword	cvmInstruction	cvm_mt_aes_enc1 cvm_mt_aes_iv cvm_mt_aes_key
syntax keyword	cvmInstruction	cvm_mt_aes_keylength cvm_mt_aes_resinp cvm_mf_gfm_mul
syntax keyword	cvmInstruction	cvm_mf_gfm_poly cvm_mf_gfm_resinp cvm_mt_gfm_mul
syntax keyword	cvmInstruction	cvm_mt_gfm_poly cvm_mt_gfm_resinp cvm_mt_gfm_xor0
syntax keyword	cvmInstruction	cvm_mt_gfm_xormul1 cvm_mf_hsh_dat cvm_mf_hsh_datw
syntax keyword	cvmInstruction	cvm_mf_hsh_iv cvm_mf_hsh_ivw cvm_mt_hsh_dat
syntax keyword	cvmInstruction	cvm_mt_hsh_datw cvm_mt_hsh_iv cvm_mt_hsh_ivw
syntax keyword	cvmInstruction	cvm_mt_hsh_startmd5 cvm_mt_hsh_startsha
syntax keyword	cvmInstruction	cvm_mt_hsh_startsha256 cvm_mt_hsh_startsha512
syntax keyword	cvmInstruction	cvm_mf_kas_key cvm_mf_kas_result cvm_mt_kas_key
syntax keyword	cvmInstruction	cvm_mt_kas_result cvm_mt_kas_enc cvm_mt_kas_enc_cbc

" cnMIPS II Instructions
syntax match	cvm2Instruction	"\<qmac[s]\?\.0[0-3]\>"
syntax keyword	cvm2Instruction	pref25 pref26 pref27 pref31 lbx lbux
syntax keyword	cvm2Instruction	lhx lhux lwx lwux ldx laa laad law lawd lai laid lad
syntax keyword	cvm2Instruction	ladd las lasd lac lacd zcb zcbt
syntax keyword	cvm2Instruction	cvm_mf_gfm_resinp_reflect cvm_mt_gfm_mul_reflect
syntax keyword	cvm2Instruction	cvm_mt_gfm_xor0_reflect cvm_mt_gfm_xormul1_reflect
syntax keyword	cvm2Instruction	cvm_mf_snow3g_lfsr cvm_mf_snow3g_fsm
syntax keyword	cvm2Instruction	cvm_mf_snow3g_result cvm_mt_snow3g_lfsr
syntax keyword	cvm2Instruction	cvm_mt_snow3g_fsm cvm_mt_snow3g_result
syntax keyword	cvm2Instruction	cvm_mt_snow3g_start cvm_mt_snow3g_more
syntax keyword	cvm2Instruction	cvm_mf_sms4_iv cvm_mf_sms4_key cvm_mf_sms4_resinp
syntax keyword	cvm2Instruction	cvm_mt_sms4_dec_cbc0 cvm_mt_sms4_dec_cbc1
syntax keyword	cvm2Instruction	cvm_mt_sms4_dec0 cvm_mt_sms4_dec1 cvm_mt_sms4_enc_cbc0
syntax keyword	cvm2Instruction	cvm_mt_sms4_enc_cbc1 cvm_mt_sms4_enc0 cvm_mt_sms4_enc1
syntax keyword	cvm2Instruction	cvm_mt_sms4_iv cvm_mt_sms4_key cvm_mt_sms4_resnip

syntax keyword	PseuInstruction	li move dli la dla negu not beqz bnez blt bge bgt

hi def link	mipsTodo	Todo
hi def link	mipsComment	Comment
hi def link	mipsNumber	Number
hi def link	mipsString	String
hi def link	mipsLabel	Label
hi def link	mipsFunction	Function
hi def link	mipsIdentifier	Identifier
hi def link	mipsDefine	Macro
hi def link	mipsMacro	Macro
hi def link	mipsIncluded	String
hi def link	mipsInclude	Include
hi def link	mipsRegister	Type
hi def link	mipsDirective	Type
hi def link	mipsInstruction	Statement
hi def link	cvmInstruction	Statement
hi def link	cvm2Instruction	Statement
hi def link	PseuInstruction	Identifier

let b:current_syntax = "mips"
