



	SECTION	code


_main	EXPORT


*******************************************************************************

* FUNCTION main(): defined at receiver.c:29
_main	EQU	*
* Prototype: int main(void)
* Calling convention: 0 (CMOC Default)
	PSHS	U
	LEAU	,S
	LEAS	-38,S
* Local non-static variable(s):
*    -38,U:    1 byte : i: unsigned char: line 31
*    -37,U:   32 bytes: regs: unsigned char[]: line 32
*     -5,U:    1 byte : byte: unsigned char: line 33
*     -4,U:    1 byte : checksum: unsigned char: line 34
*     -3,U:    1 byte : calc: unsigned char: line 35
*     -2,U:    2 bytes: frameCount: unsigned int: line 36
* Line receiver.c:36: init of variable frameCount
	CLRA
	CLRB
	STD	-2,U		variable frameCount
* Line receiver.c:39: assignment: =
	LDB	#$03
	STB	$A000
* Line receiver.c:40: assignment: =
	LDB	#$03
	STB	$A000
* Line receiver.c:41: assignment: =
	LDB	#$14
	STB	$A000
* Line receiver.c:44: function call: writeString()
	LDX	#S00021		"\r\nSAA1099 Receiver v1.0\r\n" (optim: removePCRIfRelocatabilityNotSupported)
	PSHS	X		C function argument 1 of writeString(): const char[]
	JSR	_writeString
	LEAS	2,S
* Line receiver.c:47: function call: testPattern()
	JSR	_testPattern
* Line receiver.c:50: function call: writeString()
	LDX	#S00022		"Waiting for frames...\r\n" (optim: removePCRIfRelocatabilityNotSupported)
	PSHS	X		C function argument 1 of writeString(): const char[]
	JSR	_writeString
	LEAS	2,S
* Line receiver.c:52: while
* optim: branchToNextLocation
L00029	EQU	*		while body
* Line receiver.c:57: do-while
L00032	EQU	*		do-while body
* Line receiver.c:56: assignment: =
* Line receiver.c:56: function call: readByte()
	JSR	_readByte
	STB	-5,U
* Useless label L00033 removed
* optim: storeLoad
	CMPB	#$FF
	BNE	L00032
* optim: branchToNextLocation
* Useless label L00034 removed
* Line receiver.c:60: for init
* Line receiver.c:60: assignment: =
	CLRB
	STB	-38,U		assignment to variable i
	BRA	L00036		jump to for condition
L00035	EQU	*
* Line receiver.c:60: for body
* Line receiver.c:61: assignment: =
* Line receiver.c:61: function call: readByte()
	JSR	_readByte
	PSHS	B		right side of assignment
	LDB	-38,U		variable i
	LEAX	-37,U		address of array regs
	ABX			add unsigned 8-bit offset
	LDB	,S+
	STB	,X
* Useless label L00037 removed
* Line receiver.c:60: for increment(s)
	INC	-38,U
L00036	EQU	*
* Line receiver.c:60: for condition
	LDB	-38,U		variable i
	CMPB	#$20
	BLO	L00035
* optim: branchToNextLocation
* Useless label L00038 removed
* Line receiver.c:65: assignment: =
* Line receiver.c:65: function call: readByte()
	JSR	_readByte
	STB	-4,U
* Line receiver.c:68: assignment: =
	CLR	-3,U		assignment to variable calc
* Line receiver.c:69: for init
* Line receiver.c:69: assignment: =
	CLRB
	STB	-38,U		assignment to variable i
	BRA	L00040		jump to for condition
L00039	EQU	*
* Line receiver.c:69: for body
* Line receiver.c:70: assignment: ^=
	LDB	-38,U		variable i
	LEAX	-37,U		address of array regs
	ABX			add unsigned 8-bit offset
	LDB	,X		get r-value
	PSHS	B		right side of xor assignment
	LDB	-3,U
	EORB	,S+
	STB	-3,U
* Useless label L00041 removed
* Line receiver.c:69: for increment(s)
	INC	-38,U
L00040	EQU	*
* Line receiver.c:69: for condition
	LDB	-38,U		variable i
	CMPB	#$20
	BLO	L00039
* optim: branchToNextLocation
* Useless label L00042 removed
* Line receiver.c:73: if
	LDB	-3,U		variable calc
	CMPB	-4,U		variable checksum
	LBNE	L00029		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00043 removed
* Line receiver.c:73
* Line receiver.c:74: post-increment
	LDX	-2,U		variable `frameCount', declared at receiver.c:74
	LEAX	1,X
	STX	-2,U
* Line receiver.c:77: function call: writeAllRegisters()
	LEAX	-37,U		address of array regs
	PSHS	X		C function argument 1 of writeAllRegisters(): unsigned char[]
	JSR	_writeAllRegisters
	LEAS	2,S
* Line receiver.c:81: function call: writeString()
	LDX	#S00023		"\rFrame " (optim: removePCRIfRelocatabilityNotSupported)
	PSHS	X		C function argument 1 of writeString(): const char[]
	JSR	_writeString
	LEAS	2,S
* Line receiver.c:82: function call: writeHex16()
	LDD	-2,U		variable `frameCount', declared at receiver.c:36
	PSHS	B,A		C function argument 1 of writeHex16(): unsigned int
	JSR	_writeHex16
	LEAS	2,S
* Line receiver.c:83: function call: writeString()
	LDX	#S00024		": " (optim: removePCRIfRelocatabilityNotSupported)
	PSHS	X		C function argument 1 of writeString(): const char[]
	JSR	_writeString
	LEAS	2,S
* Line receiver.c:84: for init
* Line receiver.c:84: assignment: =
	CLRB
	STB	-38,U		assignment to variable i
	BRA	L00046		jump to for condition
L00045	EQU	*
* Line receiver.c:84: for body
* Line receiver.c:85: function call: writeHex()
	LDB	-38,U		variable i
	LEAX	-37,U		address of array regs
	ABX			add unsigned 8-bit offset
	LDB	,X		get r-value
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 1 of writeHex(): unsigned char
	JSR	_writeHex
	LEAS	2,S
* Line receiver.c:86: function call: writeByte()
	LDB	#$20		decimal 32 signed
	SEX			promoting byte argument to word
	PSHS	B,A		C function argument 1 of writeByte(): char
	JSR	_writeByte
	LEAS	2,S
* Useless label L00047 removed
* Line receiver.c:84: for increment(s)
	INC	-38,U
L00046	EQU	*
* Line receiver.c:84: for condition
	LDB	-38,U		variable i
	CMPB	#$20
	BLO	L00045
* optim: branchToNextLocation
* Useless label L00048 removed
* Useless label L00044 removed
* Useless label L00049 removed
* Useless label L00030 removed
	LBRA	L00029		go to start of while body
* Useless label L00031 removed
* Inline assembly:

	swi		receiver.c:100

* End of inline assembly.
* Line receiver.c:101: return with value
	CLRA
	CLRB
* optim: branchToNextLocation
* Useless label L00011 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION main(): defined at receiver.c:29
funcend_main	EQU *
funcsize_main	EQU	funcend_main-_main


*******************************************************************************

* FUNCTION testPattern(): defined at receiver.c:106
_testPattern	EQU	*
.static.function.testPattern	EQU	*
* Prototype: void testPattern(void)
* Calling convention: 0 (CMOC Default)
	PSHS	U
	LEAU	,S
	LEAS	-6,S
* Local non-static variable(s):
*     -6,U:    1 byte : ch: unsigned char: line 108
*     -5,U:    1 byte : freq: unsigned char: line 109
*     -4,U:    1 byte : octave: unsigned char: line 110
*     -3,U:    1 byte : bit: unsigned char: line 111
*     -2,U:    2 bytes: d: unsigned int: line 112
* Line receiver.c:114: function call: writeString()
	LDX	#S00025		"SAA1099: C-E-G-C-E-G sweep\r\n" (optim: removePCRIfRelocatabilityNotSupported)
	PSHS	X		C function argument 1 of writeString(): const char[]
	JSR	_writeString
	LEAS	2,S
* Line receiver.c:117: function call: writeRegister()
	LDX	#$02		decimal 2 signed (optim: optimizeConsecutiveFunctionArguments)
* optim: optimizeConsecutiveFunctionArguments
	CLRA
	LDB	#$1C		decimal 28 signed
	PSHS	X,B,A		C function argument 1 of writeRegister(): int (optim: optimizeConsecutiveFunctionArguments)
	JSR	_writeRegister
	LEAS	4,S
* Line receiver.c:118: function call: writeRegister()
	LDX	#$01		decimal 1 signed (optim: optimizeConsecutiveFunctionArguments)
* optim: optimizeConsecutiveFunctionArguments
	CLRA
	LDB	#$1C		decimal 28 signed
	PSHS	X,B,A		C function argument 1 of writeRegister(): int (optim: optimizeConsecutiveFunctionArguments)
	JSR	_writeRegister
	LEAS	4,S
* Line receiver.c:119: function call: writeRegister()
	CLRA
	CLRB
	PSHS	B,A		C function argument 2 of writeRegister(): int
	LDB	#$14		optim: changeLoadDToLoadB
	PSHS	B,A		C function argument 1 of writeRegister(): int
	JSR	_writeRegister
	LEAS	4,S
* Line receiver.c:121: for init
* Line receiver.c:121: assignment: =
	CLRB
	STB	-6,U		assignment to variable ch
	LBRA	L00051		jump to for condition
L00050	EQU	*
* Line receiver.c:121: for body
* Line receiver.c:122: if
	LDB	-6,U		variable `ch', declared at receiver.c:108
* optim: loadCmpZeroBeqOrBne
	BNE	L00055		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00054 removed
* Line receiver.c:122
* Line receiver.c:122: assignment: =
	LDB	#$21
	STB	-5,U		assignment to variable freq
* Line receiver.c:122: assignment: =
	LDB	#$03
	STB	-4,U		assignment to variable octave
* Line receiver.c:122: assignment: =
	LDB	#$01
	STB	-3,U		assignment to variable bit
	LBRA	L00056		jump over else clause
L00055	EQU	*		else clause of if() started at receiver.c:122
* Line receiver.c:127
* Line receiver.c:123: if
	LDB	-6,U		variable ch
	CMPB	#$01
	BNE	L00058		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00057 removed
* Line receiver.c:123
* Line receiver.c:123: assignment: =
	LDB	#$84
	STB	-5,U		assignment to variable freq
* Line receiver.c:123: assignment: =
	LDB	#$03
	STB	-4,U		assignment to variable octave
* Line receiver.c:123: assignment: =
	LDB	#$02
	STB	-3,U		assignment to variable bit
	LBRA	L00059		jump over else clause
L00058	EQU	*		else clause of if() started at receiver.c:123
* Line receiver.c:127
* Line receiver.c:124: if
	LDB	-6,U		variable ch
	CMPB	#$02
	BNE	L00061		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00060 removed
* Line receiver.c:124
* Line receiver.c:124: assignment: =
	LDB	#$C0
	STB	-5,U		assignment to variable freq
* Line receiver.c:124: assignment: =
	LDB	#$03
	STB	-4,U		assignment to variable octave
* Line receiver.c:124: assignment: =
	LDB	#$04
	STB	-3,U		assignment to variable bit
	BRA	L00062		jump over else clause
L00061	EQU	*		else clause of if() started at receiver.c:124
* Line receiver.c:127
* Line receiver.c:125: if
	LDB	-6,U		variable ch
	CMPB	#$03
	BNE	L00064		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00063 removed
* Line receiver.c:125
* Line receiver.c:125: assignment: =
	LDB	#$21
	STB	-5,U		assignment to variable freq
* Line receiver.c:125: assignment: =
	LDB	#$04
	STB	-4,U		assignment to variable octave
* Line receiver.c:125: assignment: =
	LDB	#$08
	STB	-3,U		assignment to variable bit
	BRA	L00065		jump over else clause
L00064	EQU	*		else clause of if() started at receiver.c:125
* Line receiver.c:127
* Line receiver.c:126: if
	LDB	-6,U		variable ch
	CMPB	#$04
	BNE	L00067		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00066 removed
* Line receiver.c:126
* Line receiver.c:126: assignment: =
	LDB	#$84
	STB	-5,U		assignment to variable freq
* Line receiver.c:126: assignment: =
	LDB	#$04
	STB	-4,U		assignment to variable octave
* Line receiver.c:126: assignment: =
	LDB	#$10
	STB	-3,U		assignment to variable bit
	BRA	L00068		jump over else clause
L00067	EQU	*		else clause of if() started at receiver.c:126
* Line receiver.c:127
* Line receiver.c:127: assignment: =
	LDB	#$C0
	STB	-5,U		assignment to variable freq
* Line receiver.c:127: assignment: =
	LDB	#$04
	STB	-4,U		assignment to variable octave
* Line receiver.c:127: assignment: =
	LDB	#$20
	STB	-3,U		assignment to variable bit
L00068	EQU	*		end of if() started at receiver.c:126
L00065	EQU	*		end of if() started at receiver.c:125
L00062	EQU	*		end of if() started at receiver.c:124
L00059	EQU	*		end of if() started at receiver.c:123
L00056	EQU	*		end of if() started at receiver.c:122
* Line receiver.c:129: function call: writeRegister()
	LDB	-3,U		variable `bit', declared at receiver.c:111
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 2 of writeRegister(): unsigned char
	LDB	#$14		optim: changeLoadDToLoadB
	PSHS	B,A		C function argument 1 of writeRegister(): int
	JSR	_writeRegister
	LEAS	4,S
* Line receiver.c:130: function call: writeRegister()
	CLRA
	LDB	#$FF		decimal 255 signed
	PSHS	B,A		C function argument 2 of writeRegister(): int
	LDB	-6,U		variable `ch', declared at receiver.c:108
* optim: stripExtraClrA_B
	PSHS	B,A		C function argument 1 of writeRegister(): unsigned char
	JSR	_writeRegister
	LEAS	4,S
* Line receiver.c:131: function call: writeRegister()
	LDB	-5,U		variable `freq', declared at receiver.c:109
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 2 of writeRegister(): unsigned char
	LDB	-6,U		variable ch
	ADDB	#$08		8
* optim: stripExtraClrA_B
	PSHS	B,A		C function argument 1 of writeRegister(): unsigned char
	JSR	_writeRegister
	LEAS	4,S
* Line receiver.c:133: if
	LDB	-6,U		variable ch
	ANDB	#$01
* optim: optimizeAndbTstb
	BEQ	L00070		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00069 removed
* Line receiver.c:134
* Line receiver.c:134: function call: writeRegister()
	LDB	-4,U		to be multiplied by 16
	LSLB
	LSLB
	LSLB
	LSLB
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 2 of writeRegister(): unsigned char
	LDB	-6,U		variable `ch', declared at receiver.c:108
	LSRB
* optim: optimizeStackOperations2
* optim: optimizeStackOperations2
	ADDB	#$10		optim: optimizeStackOperations2
* optim: stripExtraClrA_B
	PSHS	B,A		C function argument 1 of writeRegister(): unsigned char
	JSR	_writeRegister
	LEAS	4,S
	BRA	L00071		jump over else clause
L00070	EQU	*		else clause of if() started at receiver.c:133
* Line receiver.c:136
* Line receiver.c:136: function call: writeRegister()
	LDB	-4,U		variable `octave', declared at receiver.c:110
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 2 of writeRegister(): unsigned char
	LDB	-6,U		variable `ch', declared at receiver.c:108
	LSRB
* optim: optimizeStackOperations2
* optim: optimizeStackOperations2
	ADDB	#$10		optim: optimizeStackOperations2
* optim: stripExtraClrA_B
	PSHS	B,A		C function argument 1 of writeRegister(): unsigned char
	JSR	_writeRegister
	LEAS	4,S
L00071	EQU	*		end of if() started at receiver.c:133
* Line receiver.c:138: function call: writeString()
	LDX	#S00026		" Ch" (optim: removePCRIfRelocatabilityNotSupported)
	PSHS	X		C function argument 1 of writeString(): const char[]
	JSR	_writeString
	LEAS	2,S
* Line receiver.c:139: function call: writeHex()
	LDB	-6,U		variable `ch', declared at receiver.c:108
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 1 of writeHex(): unsigned char
	JSR	_writeHex
	LEAS	2,S
* Line receiver.c:140: function call: writeString()
	LDX	#S00027		" on\r\n" (optim: removePCRIfRelocatabilityNotSupported)
	PSHS	X		C function argument 1 of writeString(): const char[]
	JSR	_writeString
	LEAS	2,S
* Line receiver.c:142: for init
* Line receiver.c:142: assignment: =
	CLRA
	CLRB
	STD	-2,U
	BRA	L00073		jump to for condition
L00072	EQU	*
* Line receiver.c:142: for body
* Useless label L00074 removed
* Line receiver.c:142: for increment(s)
	LDD	-2,U
	ADDD	#1
	STD	-2,U
L00073	EQU	*
* Line receiver.c:142: for condition
	LDD	-2,U		variable d
	CMPD	#$7530
	BLO	L00072
* optim: branchToNextLocation
* Useless label L00075 removed
* Line receiver.c:144: function call: writeRegister()
	CLRA
	CLRB
	PSHS	B,A		C function argument 2 of writeRegister(): int
	LDB	-6,U		variable `ch', declared at receiver.c:108
* optim: stripExtraClrA_B
	PSHS	B,A		C function argument 1 of writeRegister(): unsigned char
	JSR	_writeRegister
	LEAS	4,S
* Useless label L00052 removed
* Line receiver.c:121: for increment(s)
	INC	-6,U
L00051	EQU	*
* Line receiver.c:121: for condition
	LDB	-6,U		variable ch
	CMPB	#$06
	LBLO	L00050
* optim: branchToNextLocation
* Useless label L00053 removed
* Line receiver.c:147: function call: writeRegister()
	CLRA
	CLRB
	PSHS	B,A		C function argument 2 of writeRegister(): int
	LDB	#$14		optim: changeLoadDToLoadB
	PSHS	B,A		C function argument 1 of writeRegister(): int
	JSR	_writeRegister
	LEAS	4,S
* Line receiver.c:148: function call: writeRegister()
	CLRA
	CLRB
	PSHS	B,A		C function argument 2 of writeRegister(): int
	LDB	#$1C		optim: changeLoadDToLoadB
	PSHS	B,A		C function argument 1 of writeRegister(): int
	JSR	_writeRegister
	LEAS	4,S
* Line receiver.c:150: function call: writeString()
	LDX	#S00028		"Test complete.\r\n" (optim: removePCRIfRelocatabilityNotSupported)
	PSHS	X		C function argument 1 of writeString(): const char[]
	JSR	_writeString
* optim: removeUnneededLEAS
* Useless label L00012 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION testPattern(): defined at receiver.c:106
funcend_testPattern	EQU *
funcsize_testPattern	EQU	funcend_testPattern-_testPattern


*******************************************************************************

* FUNCTION readByte(): defined at receiver.c:155
_readByte	EQU	*
.static.function.readByte	EQU	*
* Prototype: unsigned char readByte(void)
* Calling convention: 0 (CMOC Default)
* Line receiver.c:157: while
	BRA	L00077		jump to while condition
L00076	EQU	*		while body
L00077	EQU	*		while condition at receiver.c:157
	CLRA
* LDB #$01 optim: optimizeStackOperations1
* PSHS B optim: optimizeStackOperations1
	LDB	$A000		decimal 40960
	ANDB	#1		optim: optimizeStackOperations1
* optim: optimizeAndbTstb
	BEQ	L00076		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00078 removed
* Line receiver.c:158: return with value
	LDB	$A001		decimal 40961
* optim: branchToNextLocation
* Useless label L00013 removed
	RTS
* END FUNCTION readByte(): defined at receiver.c:155
funcend_readByte	EQU *
funcsize_readByte	EQU	funcend_readByte-_readByte


*******************************************************************************

* FUNCTION writeByte(): defined at receiver.c:161
_writeByte	EQU	*
.static.function.writeByte	EQU	*
* Prototype: void writeByte(unsigned char)
* Calling convention: 0 (CMOC Default)
	PSHS	U
	LEAU	,S
* Formal parameter(s):
*      5,U:    1 byte : c: unsigned char: line 161
* Line receiver.c:163: while
	BRA	L00080		jump to while condition
L00079	EQU	*		while body
L00080	EQU	*		while condition at receiver.c:163
	CLRA
* LDB #$02 optim: optimizeStackOperations1
* PSHS B optim: optimizeStackOperations1
	LDB	$A000		decimal 40960
	ANDB	#2		optim: optimizeStackOperations1
* optim: optimizeAndbTstb
	BEQ	L00079		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00081 removed
* Line receiver.c:164: assignment: =
	LDB	5,U
	STB	$A001
* Useless label L00014 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION writeByte(): defined at receiver.c:161
funcend_writeByte	EQU *
funcsize_writeByte	EQU	funcend_writeByte-_writeByte


*******************************************************************************

* FUNCTION writeString(): defined at receiver.c:167
_writeString	EQU	*
.static.function.writeString	EQU	*
* Prototype: void writeString(const char *)
* Calling convention: 0 (CMOC Default)
	PSHS	U
	LEAU	,S
* Formal parameter(s):
*      4,U:    2 bytes: s: const char *: line 167
* Line receiver.c:169: while
	BRA	L00083		jump to while condition
L00082	EQU	*		while body
* Line receiver.c:170: function call: writeByte()
	LDX	4,U		get pointer s
	LDB	,X+		indirection with post-increment
	STX	4,U		store incremented pointer s
	SEX			promoting byte argument to word
	PSHS	B,A		C function argument 1 of writeByte(): const char
	JSR	_writeByte
	LEAS	2,S
L00083	EQU	*		while condition at receiver.c:169
	LDB	[4,U]		indirection
* optim: loadCmpZeroBeqOrBne
	BNE	L00082
* optim: branchToNextLocation
* Useless label L00084 removed
* Useless label L00015 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION writeString(): defined at receiver.c:167
funcend_writeString	EQU *
funcsize_writeString	EQU	funcend_writeString-_writeString


*******************************************************************************

* FUNCTION writeRegister(): defined at receiver.c:176
_writeRegister	EQU	*
.static.function.writeRegister	EQU	*
* Prototype: void writeRegister(unsigned char, unsigned char)
* Calling convention: 0 (CMOC Default)
	PSHS	U
	LEAU	,S
* Formal parameter(s):
*      5,U:    1 byte : reg: unsigned char: line 176
*      7,U:    1 byte : value: unsigned char: line 176
* Line receiver.c:178: assignment: =
	LDB	5,U
	STB	$B001
* Inline assembly:

	nop		receiver.c:179

* End of inline assembly.
* Inline assembly:

	nop		receiver.c:180

* End of inline assembly.
* Inline assembly:

	nop		receiver.c:181

* End of inline assembly.
* Line receiver.c:182: assignment: =
	LDB	7,U
	STB	$B000
* Useless label L00016 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION writeRegister(): defined at receiver.c:176
funcend_writeRegister	EQU *
funcsize_writeRegister	EQU	funcend_writeRegister-_writeRegister


*******************************************************************************

* FUNCTION writeAllRegisters(): defined at receiver.c:185
_writeAllRegisters	EQU	*
.static.function.writeAllRegisters	EQU	*
* Prototype: void writeAllRegisters(unsigned char *)
* Calling convention: 0 (CMOC Default)
	PSHS	U
	LEAU	,S
	LEAS	-1,S
* Formal parameter(s):
*      4,U:    2 bytes: regs: unsigned char *: line 185
* Local non-static variable(s):
*     -1,U:    1 byte : i: unsigned char: line 187
* Line receiver.c:188: for init
* Line receiver.c:188: assignment: =
	CLRB
	STB	-1,U		assignment to variable i
	BRA	L00086		jump to for condition
L00085	EQU	*
* Line receiver.c:188: for body
* Line receiver.c:189: function call: writeRegister()
	LDB	-1,U		variable i
	LDX	4,U		pointer regs
	ABX			add unsigned 8-bit offset
	LDB	,X		get r-value
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 2 of writeRegister(): unsigned char
	LDB	-1,U		variable `i', declared at receiver.c:187
* optim: stripExtraClrA_B
	PSHS	B,A		C function argument 1 of writeRegister(): unsigned char
	JSR	_writeRegister
	LEAS	4,S
* Useless label L00087 removed
* Line receiver.c:188: for increment(s)
	INC	-1,U
L00086	EQU	*
* Line receiver.c:188: for condition
	LDB	-1,U		variable i
	CMPB	#$20
	BLO	L00085
* optim: branchToNextLocation
* Useless label L00088 removed
* Useless label L00017 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION writeAllRegisters(): defined at receiver.c:185
funcend_writeAllRegisters	EQU *
funcsize_writeAllRegisters	EQU	funcend_writeAllRegisters-_writeAllRegisters


*******************************************************************************

* FUNCTION hexNibble(): defined at receiver.c:195
_hexNibble	EQU	*
.static.function.hexNibble	EQU	*
* Prototype: unsigned char hexNibble(unsigned char)
* Calling convention: 0 (CMOC Default)
	PSHS	U
	LEAU	,S
* Formal parameter(s):
*      5,U:    1 byte : v: unsigned char: line 195
* Line receiver.c:197: assignment: &=
	CLRA
* LDB #$0F optim: optimizeStackOperations1
* PSHS B optim: optimizeStackOperations1
	LDB	5,U
	ANDB	#15		optim: optimizeStackOperations1
	STB	5,U
* Line receiver.c:198: if
* optim: storeLoad
	CMPB	#$0A
	BHS	L00090		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00089 removed
* Line receiver.c:199
* Line receiver.c:199: return with value
	LDB	5,U		variable v
	ADDB	#$30		48
* Cast from `char' to byte: result already in B
	BRA	L00018		return (receiver.c:199)
L00090	EQU	*		else clause of if() started at receiver.c:198
* Useless label L00091 removed
* Line receiver.c:200: return with value
* LDB #$0A optim: optimizeStackOperations1
* PSHS B optim: optimizeStackOperations1
	LDB	5,U		variable v
	ADDB	#$41		65
	SUBB	#10		optim: optimizeStackOperations1
* Cast from `char' to byte: result already in B
* optim: branchToNextLocation
L00018	EQU	*		end of hexNibble()
	LEAS	,U
	PULS	U,PC
* END FUNCTION hexNibble(): defined at receiver.c:195
funcend_hexNibble	EQU *
funcsize_hexNibble	EQU	funcend_hexNibble-_hexNibble


*******************************************************************************

* FUNCTION writeHex(): defined at receiver.c:203
_writeHex	EQU	*
.static.function.writeHex	EQU	*
* Prototype: void writeHex(unsigned char)
* Calling convention: 0 (CMOC Default)
	PSHS	U
	LEAU	,S
* Formal parameter(s):
*      5,U:    1 byte : v: unsigned char: line 203
* Line receiver.c:205: function call: writeByte()
* Line receiver.c:205: function call: hexNibble()
	LDB	5,U		variable `v', declared at receiver.c:203
	LSRB
	LSRB
	LSRB
	LSRB
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 1 of hexNibble(): unsigned char
	JSR	_hexNibble
	LEAS	2,S
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 1 of writeByte(): unsigned char
	JSR	_writeByte
	LEAS	2,S
* Line receiver.c:206: function call: writeByte()
* Line receiver.c:206: function call: hexNibble()
	LDB	5,U		variable `v', declared at receiver.c:203
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 1 of hexNibble(): unsigned char
	JSR	_hexNibble
	LEAS	2,S
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 1 of writeByte(): unsigned char
	JSR	_writeByte
* optim: removeUnneededLEAS
* Useless label L00019 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION writeHex(): defined at receiver.c:203
funcend_writeHex	EQU *
funcsize_writeHex	EQU	funcend_writeHex-_writeHex


*******************************************************************************

* FUNCTION writeHex16(): defined at receiver.c:209
_writeHex16	EQU	*
.static.function.writeHex16	EQU	*
* Prototype: void writeHex16(unsigned int)
* Calling convention: 0 (CMOC Default)
	PSHS	U
	LEAU	,S
* Formal parameter(s):
*      4,U:    2 bytes: v: unsigned int: line 209
* Line receiver.c:211: function call: writeHex()
	LDD	4,U		variable `v', declared at receiver.c:209
	TFR	A,B		shift D 8 bits right
* optim: stripOpToDeadReg
* Cast from `unsigned int' to byte: result already in B
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 1 of writeHex(): unsigned char
	JSR	_writeHex
	LEAS	2,S
* Line receiver.c:212: function call: writeHex()
	LDD	4,U		variable `v', declared at receiver.c:209
* Cast from `unsigned int' to byte: result already in B
	CLRA			promoting byte argument to word
	PSHS	B,A		C function argument 1 of writeHex(): unsigned char
	JSR	_writeHex
* optim: removeUnneededLEAS
* Useless label L00020 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION writeHex16(): defined at receiver.c:209
funcend_writeHex16	EQU *
funcsize_writeHex16	EQU	funcend_writeHex16-_writeHex16


	ENDSECTION




	SECTION	initgl_start


INITGL	EXPORT
INITGL	EQU	*


	ENDSECTION




	SECTION	initgl




*******************************************************************************

* Initialize global variables.


	ENDSECTION




	SECTION	rodata


string_literals_start	EQU	*


*******************************************************************************

* STRING LITERALS
S00021	EQU	*
	FCB	$0D
	FCB	$0A
	FCC	"SAA1099 Receiver v1.0"
	FCB	$0D
	FCB	$0A
	FCB	0
S00022	EQU	*
	FCC	"Waiting for frames..."
	FCB	$0D
	FCB	$0A
	FCB	0
S00023	EQU	*
	FCB	$0D
	FCC	"Frame "
	FCB	0
S00024	EQU	*
	FCC	": "
	FCB	0
S00025	EQU	*
	FCC	"SAA1099: C-E-G-C-E-G sweep"
	FCB	$0D
	FCB	$0A
	FCB	0
S00026	EQU	*
	FCC	" Ch"
	FCB	0
S00027	EQU	*
	FCC	" on"
	FCB	$0D
	FCB	$0A
	FCB	0
S00028	EQU	*
	FCC	"Test complete."
	FCB	$0D
	FCB	$0A
	FCB	0
string_literals_end	EQU	*


*******************************************************************************

* READ-ONLY GLOBAL VARIABLES


	ENDSECTION




	SECTION	rwdata


* Statically-initialized global variables
* Statically-initialized local static variables


	ENDSECTION




	SECTION	bss


bss_start	EQU	*
* Uninitialized global variables
* Uninitialized local static variables
bss_end	EQU	*


	ENDSECTION




	SECTION	initgl_end


	RTS			end of global variable initialization


	ENDSECTION




*******************************************************************************



	SECTION	program_end


program_end	EXPORT
program_end	EQU	*


	ENDSECTION




*******************************************************************************

* Importing 0 utility routine(s).


*******************************************************************************

	END
