.data
	cadena: .space 400
	Operadores:.space 400
	Salida: .space 400
	cadenaError: .asciiz "Caracter erroneo en la cadena"
	A: .space 400
	B: .space 400
	
.text
main:
	#obtenemos la cadena de entrada por el teclado
	la $a0, cadena
	la $a1, Operadores
	la $a2, Salida
	li $v0, 8
	syscall
	la $a0, cadena #parametros de la funcion cambioFinCadena
	jal cambioFinCadena
	la $a0, cadena #parametros de la funcion pone_parentesis
	jal pone_parentesis
	la $a0, cadena
	la $a2, Salida
	jal CreaPolaca
	beq $v1, 1, errorDeCaracter
	la $a0, Salida
	li $v0, 4
	syscall
	la $a0, Salida
	la $a1, Operadores
	jal Resolver
	la $a1, A
	la $a2, B
	add $a0, $v0, $zero
	jal binarioADecimal
	la $a0, B
	li $v0,4
	syscall
finPrograma:
	li $v0, 10
	syscall

errorDeCaracter:
	la $a0, cadenaError
	add $v0, $zero, 4
	syscall
	j finPrograma
	
	
	
	
#-------Metodo que añade parentesis al principio y final de la cadena almacenada en memoria-----------------------------
pone_parentesis:
	add $t0, $a0, $zero
	addi $t1, $zero, 40 #registro que contiene el caracter que se va a cambiar, abrir parentesis al emepezar
	addi $t3, $zero, 41 #valro de cerrar parentesis
bucle1:
	add $t2, $zero, $zero
	lb $t2, 0($t0)
	sb $t1, 0($t0)
	add $t1, $t2, $zero
	add $t0, $t0, 1
	beq $t2, $zero, salir1
	j bucle1
salir1:
	sb $t3, 0($t0)
	jr $ra
	
#-------Metodo que cambiaºel fin de la cadena de un salto de linea a valor nulo-----------------------------------------	
cambioFinCadena:
	add $t0, $a0, $zero
	back1:
	lb $t1, 0($t0)
	addi $t0, $t0, 1
	beq $t1, 0, acabar
	beq $t1, 10, acabar
	j back1
	acabar:
	addi $t0, $t0, -1
	sb $zero, 0($t0)
	jr $ra
#-------Metodo que recorre la cadena de entrada y va creando la pila de salida con notacion polaca
CreaPolaca:
	add $t0, $zero, $a0	#cadena de entrada
	add $t2, $zero, $a2	#pila de salida
	addi $t4, $zero, 47	#ascii anterior al 0
	addi $t7, $zero, 32	#espacio
	
back:
	lb $t3, 0($t0)		#cargamos el caracter que toca de la cadena de entrada
	slt $t5, $t4, $t3	
	slti $t6, $t3, 58
	and $t5, $t5, $t6	#ponemos a 1 $t5 si es el ascii de un numero
	beq $t5, 1, numero	
	beq $t5, 0, comprobar
	j back
	
numero:
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	addi $t0, $t0, 1
	j back
	
comprobar:			#comprobamos si el caracter anterior no es un numero y si no lo es guardamos un espacio
	addi $t0,$t0, -1	
	lb $t5, 0($t0)
	slt $t8, $t4, $t5
	slti $t6, $t5, 58
	and $t8, $t8, $t6
	beq $t8, 1, guardar_espacio
	addi $t0,$t0, 1	
	j distinto_numero
	
guardar_espacio:
	sb $t7, 0($t2)
	addi $t0,$t0, 1	
	addi $t2, $t2, 1
	j distinto_numero
	
distinto_numero:
	beq $t3, 0, salirPolaca		#se ha acabado la cadena de entrada	
	beq $t3, 40, parentesisizq	
	beq $t3, 41, parentesisder
	j saque_pila
parentesisizq:				#lo ponemos en la pila de operadores
	lb $t5, -1($t0)
	slt $t8, $t4, $t5
	slti $t6, $t5, 58
	and $t8, $t8, $t6
	beq $t8, 1, error
	lb $t5, 1($t0)
	beq $t5, 43, mete0	#+
	beq $t5, 45, mete0	#-
	beq $t5, 42, error	#*
	beq $t5, 47, error	#/
	beq $t5, 94, error	#^
return:
	addi $sp, $sp, -1
	sb $t3, 0($sp)
	addi $t0, $t0, 1
	j back

mete0:
	addi $t9, $zero, 48
	sb $t9, 0($t2)
	addi $t2, $t2, 1
	addi $t9, $zero, 32
	sb $t9, 0($t2)
	addi $t2, $t2, 1
	add $t9, $zero, $zero
	j return
	
parentesisder:				#sacamos de la pila de operadores y metemos en la pila de salida hasta encontrar un parentesis izquierda
	lb $t5, -1($t0)
	beq $t5, 43, error	#+
	beq $t5, 45, error	#-
	beq $t5, 42, error	#*
	beq $t5, 47, error	#/
	beq $t5, 94, error	#^
	lb $t5, 1($t0)
	slt $t8, $t4, $t5
	slti $t6, $t5, 58
	and $t8, $t8, $t6
	beq $t8, 1, error
	lb $t3, 0($sp)
	addi $sp, $sp, 1
	beq $t3, 40, puente
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	j parentesisder
puente:
	addi $t0, $t0, 1
	j back
saque_pila:
	lb $t5, 0($sp)
	beq $t5, 40, pp4	#( parentesis izq porque en la pila nunca va haber un paréntesis derecha
	beq $t5, 43, pp3	#+
	beq $t5, 45, pp3	#-
	beq $t5, 42, pp2	#*
	beq $t5, 47, pp2	#/
	beq $t5, 94, pp1	#^
	j operador
pp4:
	addi $t1, $zero, 4
	j operador 
pp3:
	addi $t1, $zero, 3
	j operador 
pp2:
	addi $t1, $zero, 2
	j operador 
pp1:
	addi $t1, $zero, 1
operador:
	beq $t3, 43, p3	#+
	beq $t3, 45, p3	#-
	beq $t3, 42, p2	#*
	beq $t3, 47, p2	#/
	beq $t3, 94, p1	#^
	addi $v0, $zero, 1	#caracter eroneo
	jr $ra
p3:
	addi $t8, $zero, 3
	slt $t9, $t1, $t8	#
	beq $t9, $zero, apila
	j desapila
p2:
	addi $t8, $zero, 2
	slt $t9, $t1, $t8	#
	beq $t9, $zero, apila
	j desapila
p1:
	addi $t8, $zero, 1
	slt $t9, $t1, $t8	#
	beq $t9, $zero, apila
	j desapila	

apila:
	addi $sp, $sp, -1
	sb $t3, 0($sp)
	addi $t0, $t0, 1
	j back
desapila:
	lb $t5, 0($sp)
	addi $sp, $sp, 1
	sb $t5, 0($t2)
	addi $t2, $t2, 1
	j saque_pila
error:
	addi $v1, $zero, 1	#caracter eroneo
	j salirPolaca
salirPolaca: 
	addi $v0, $zero, 0
	jr $ra
	
#-------Metodo que resuelve la notación polaca---------------------------------------------------
Resolver:
	add $t0, $zero, $a0
	addi $t1, $zero, 47
	add $t5, $zero, $a1
	
backResuelve:
	lb $t2, 0($t0)
	beq $t2, 0, fin
	slt $t3, $t1, $t2
	slti $t4, $t2, 58
	and $t3, $t3, $t4
	add $t4, $zero, $zero
	beq $t3, 1, esNumero
	beq $t2, 43, suma	#+
	beq $t2, 45, resta	#-
	beq $t2, 42, multiplica	#*
	beq $t2, 47, divide	#/
	beq $t2, 94, eleva	#^
	

esNumero:	#calculamos el valor del numero hasta el siguiente espacio
	lb $t2, 0($t0)
	addi $t0, $t0, 1
	beq $t2, 32, apilar
	add $t2, $t2, -48
	mul $t4, $t4, 10
	add $t4, $t4, $t2
	j esNumero
	
apilar:
	sw $t4, 0($t5)
	add $t5, $t5, 4
	j backResuelve

suma: 
	lw $t6, -8($t5)
	lw $t7, -4($t5)
	add $t8, $t6, $t7
	sw $t8, -8($t5)
	addi $t5, $t5, -4
	addi $t0, $t0, 1
	j backResuelve

resta: 
	lw $t6, -8($t5)
	lw $t7, -4($t5)
	sub $t8, $t6, $t7
	sw $t8, -8($t5)
	addi $t5, $t5, -4
	addi $t0, $t0, 1
	j backResuelve

multiplica: 
	lw $t6, -8($t5)
	lw $t7, -4($t5)
	mul $t8, $t6, $t7
	sw $t8, -8($t5)
	addi $t5, $t5, -4
	addi $t0, $t0, 1
	j backResuelve
	
divide: 
	lw $t6, -8($t5)
	lw $t7, -4($t5)
	div $t6, $t7
	mflo $t8
	sw $t8, -8($t5)
	addi $t5, $t5, -4
	addi $t0, $t0, 1
	j backResuelve
	
eleva: 
	lw $t6, -8($t5)
	lw $t7, -4($t5)
	addi $t8, $zero,1
repetir:
	mul $t8,$t8,$t6
	sub $t7, $t7, 1
	bnez $t7, repetir
	sw $t8, -8($t5)
	addi $t5, $t5, -4
	addi $t0, $t0, 1
	j backResuelve
fin: 
	lw $v0, -4($t5)
	jr $ra
	
#-----------------------------------------------------------------------------------------------------------
binarioADecimal:
	move $t1, $zero
	move $t2, $zero
	move $t3, $zero
	move $t4, $zero
	move $t5, $zero
	move $t6, $zero
	move $t7, $zero
	add $t0, $a0, $zero		#cargamso el valor del numero
	addi $t1, $zero, 10		
	add $t3, $a1, $zero
	add $t7, $a2, $zero
	add $t4, $zero, $zero 		#contador que lleva la cuenta del numero de digitos
	andi $t6, $t0, 0xa0000000	#aqui comparamos para ver si es negativoel digito de ma s a la izquierda
	srl $t6, $t6, 31
	beq $t6, 1, negativo		#si es ngativo llamamos a esta etiqueta que nos va a guardar el - en la direccion de memoria final en la rpimera posicion
	j bucle2
negativo:
	move $t6, $zero
	sub $t0, $zero, $t0		#cambiamos el numero para tratarlo como si fuese un numero en valor absoluto
	addi $t6, $t6, 45
	sb $t6, 0($t7)
	addi $t7, $t7, 1		#aqui guardamos el signo en la primera posicion de la direccion de memoria final
		
bucle2:
	div $t0, $t1
	add $t4, $t4, 1
	mflo $t0	#gusrdamos el cociente en $t0
	mfhi $t2	#gusardamos el resto en $t2
	beq $t2, 45, negativo	#saber si el numero es negativo
	add $t2, $t2, 48	#sumamos 48 para conseguir el valor ascii 
	sb $t2, 0($t3)
	addi $t3, $t3, 1
	beq $t0, 0, voltear
	j bucle2
	


voltear: 			#esta funcion es para cambiar el orden de los numeros para ello utilizamos la pila
	sub $t3, $t3, 1		#aqui le restamos las veces que le sumamos 1 a la direccion de memoria anteriormente para poder llamar a la primera posicon
	sub $t4, $t4, 1
	beqz $t4, reinicia_contador	
	j voltear
	reinicia_contador:
	addi $t4, $zero, 0	#aqui reiniciamos el contador a cero otra vez
	apila1:			
	lb $t5, 0($t3)
	beqz $t5, desapila1
	addi $sp, $sp, -1
	sb $t5, 0($sp)
	addi $t4, $t4, 1
	addi $t3, $t3, 1
	j apila1
	desapila1:
	lb $t5, 0($sp) 
 	addi $sp, $sp, 1
 	sb $t5, 0($t7) 
 	addi $t7, $t7, 1 
 	addi $t4, $t4, -1 
 	bnez $t4, desapila1
 	sb $zero, ($t7)
 	j salir2
salir2:

	jr $ra

	
