INITIAL:
	#li   sp, 0x10000            # Initialize stack pointer
    	#csrrwi zero, 0x300, 0x8     # enable externel interrupt

  	lui  s1, 0xFFFFF

    	#li   a0, 0x12345678
    	#ecall                       # Test ecall
	
MAIN:
	lw   s0, 0x70(s1)           # Read switches
	lw	 a7, 0x78(s1)			# Read buttons
	
	sw   s0, 0x60(s1)           # Write LEDs
	andi s3,s0,0xFF		#B=SW[7:0]
	srli s2,s0,8
	andi s2,s2,0xFF		#A=SW[15:8]右移8bit
	srli s4,s0,21
	andi s4,s4,0x7	#op=SW[23:21]右移21bit
	
PREPARE:
	andi s8,s2,0xF	#A小数部分
	srli s7,s2,4	#A整数部分
	andi s10,s3,0xF	#B小数部分
	srli s9,s3,4	#B整数部分
	
JUDGE:
	addi a0,x0,0
	addi a1,x0,1
	addi a2,x0,2
	addi a3,x0,3
	addi a4,x0,4
	addi a5,x0,5
	addi a6,x0,6	#判断SW[23:21]op指令
	
	add s5,x0,x0
	add s6,x0,x0
	
	beq s4,a0,OPT_RESET
	beq s4,a1,OPT_ADD
	beq s4,a2,OPT_SUB
	beq s4,a3,OPT_MUL
	beq s4,a4,OPT_DIV
	beq s4,a5,OPT_RANDOM
	beq s4,a6,OPT_BUTTON
	jal MAIN
	
#s5整数部分，s6小数部分
OPT_RESET:
	add s5,x0,x0
	add s6,x0,x0
	jal SHOW
	
OPT_ADD:
	add s6,s8,s10
	addi t0,x0,9
	add s5,s7,s9
	bge t0,s6,SHOW	#小数大于10
	addi s5,s5,1
	addi s6,s6,-10
	jal SHOW

OPT_SUB:
	bge s7,s9,sub1	#判断整数部分大小
	#B-A B>A
	sub s5,s9,s7
	sub s6,s10,s8
	jal jiewei
	sub1:
	beq s7,s9,sub2	#判断整数部分是否一致，特殊处理
	#A-B A>B且AB整数部分不一致
	sub s5,s7,s9
	sub s6,s8,s10
	jal jiewei
	sub2:	#整数部分一致
	sub s5,s7,s8
	bge s8,s10,sub3	#判断小数部分大小
	sub s6,s10,s8
	jal jiewei
	sub3:
	sub s6,s8,s10
	jiewei:	#A-B和B-A部分小数为负借位
	bge s6,x0,SHOW
	addi s6,s6,10
	addi s5,s5,-1
	jal SHOW
	
OPT_MUL:
	add s5,s7,x0
	add s6,s8,x0
	addi t0,x0,9
	for_mul:
	bge x0,s3,end_mul	#乘法
		slli s5,s5,1
		slli s6,s6,1
		bge t0,s6,end_mul_1	#小数大于10则进位
			addi s6,s6,-10
			addi s5,s5,1
		end_mul_1:
		addi s3,s3,-1
		jal for_mul
	end_mul:
	jal SHOW
	
OPT_DIV:
	addi t0,x0,1000
	addi s6,x0,0
	for_1000:		#根据小数定义几千个0.0001
	bge x0,s8,end_1000
		addi s6,s6,1000
		addi s8,s8,-1
		jal for_1000
	end_1000:
	add s5,s7,x0
	addi t2,x0,1
	for_div:		#除法
	bge x0,s3,end_div
		andi t1,s5,0x1
		srli s5,s5,1
		srli s6,s6,1
		bne t1,t2,end_div1		#整数为奇数，小数加0.5
			addi s6,s6,1000
			addi s6,s6,1000
			addi s6,s6,1000
			addi s6,s6,1000
			addi s6,s6,1000
		end_div1:
		addi s3,s3,-1
		jal for_div
	end_div:
	jal SHOW
	
OPT_RANDOM:
	add s11,s2,x0
	slli s11,s11,8
	add s11,s11,s3
	slli s11,s11,8
	add s11,s11,s2
	slli s11,s11,8
	add s11,s11,s3	#种子{A,B,A,B}
	
	random:
	srli t3,s11,31	#a31
	srli t4,s11,21	
	andi t4,t4,0x1	#a21
	srli t5,s11,1
	andi t5,t5,0x1	#a1
	andi t6,s11,0x1	#a0
	
	xor s6,t3,t4
	xor s6,s6,t5
	xor s6,s6,t6
	
	slli s11,s11,1
	add s11,s11,s6
	
	sw  s11, 0x00(s1)           # Write 7-seg LEDs
	# 等待1s
	addi x28,x0,1000
	
	forlst1:
	beq x28,x0,Exit1
	addi x29,x0,1000
		forlst2:
		beq x29,x0,Exit2
			addi x30,x0,6
			forlst3:
			beq x30,x0,Exit3
				addi x30,x30,-1
				jal forlst3
			Exit3:
			addi x29,x29,-1
			jal forlst2
		Exit2:
		addi x28,x28,-1
		jal forlst1
	Exit1:
	lw   t0, 0x70(s1)           # Read switches
	bne s0,t0,MAIN
	jal random


OPT_BUTTON:
	add s5,x0,x0
	for_button:
		bge x0,a7,exit_button
		addi s5,s5,1
		srli a7,a7,1
		jal for_button
	exit_button:
	jal SHOW
	
SHOW:
	addi t1,x0,999
	addi t2,x0,99
	addi t3,x0,9
	addi t6,x0,0
	forist_1000:
	bge t1,s5,less_1000
		addi t6,t6,1
		addi s5,s5,-1000
		jal forist_1000
	less_1000:
	bge t3,t6,cut
		addi,t6,t6,-10
	cut:
	slli t6,t6,4
	
	forist_100:
	bge t2,s5,less_100
		addi t6,t6,1
		addi s5,s5,-100
		jal forist_100
	less_100:
	slli t6,t6,4
	forist_10:
	bge t3,s5,less_10
		addi t6,t6,1
		addi s5,s5,-10
		jal forist_10
	less_10:
	slli t6,t6,4
	forist_1:
	bge x0,s5,less_1
		addi t6,t6,1
		addi s5,s5,-1
		jal forist_1
	less_1:
	slli t6,t6,4
	
	
	#小数部分显示
	forist_1000_2:
	bge t1,s6,less_1000_2
		addi t6,t6,1
		addi s6,s6,-1000
		jal forist_1000_2
	less_1000_2:
	slli t6,t6,4
	forist_100_2:
	bge t2,s6,less_100_2
		addi t6,t6,1
		addi s6,s6,-100
		jal forist_100_2
	less_100_2:
	slli t6,t6,4
	forist_10_2:
	bge t3,s6,less_10_2
		addi t6,t6,1
		addi s6,s6,-10
		jal forist_10_2
	less_10_2:
	slli t6,t6,4
	forist_1_2:
	bge x0,s6,less_1_2
		addi t6,t6,1
		addi s6,s6,-1
		jal forist_1_2
	less_1_2:
	sw  t6, 0x00(s1)           # Write 7-seg LEDs
	jal MAIN



	
	
	
