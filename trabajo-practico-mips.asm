.data
slist: 	.word 0
cclist: .word 0
wclist: .word 0
schedv: .space 32
menu: 	.ascii "Colecciones de objetos categorizados\n"
	.ascii "====================================\n"
	.ascii "1-Nueva categoria\n"
	.ascii "2-Siguiente categoria\n"
	.ascii "3-Categoria anterior\n"
	.ascii "4-Listar categorias\n"
	.ascii "5-Borrar categoria actual\n"
	.ascii "6-Anexar objeto a la categoria actual\n"
	.ascii "7-Listar objetos de la categoria\n"
	.ascii "8-Borrar objeto de la categoria\n"
	.ascii "0-Salir\n"
	.asciiz "Ingrese la opcion deseada: "
error: 	.asciiz "Error: "
return: .asciiz "\n"
catName:.asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria:"
idObj: 	.asciiz "\nIngrese el ID del objeto a eliminar: "
objName:.asciiz "\nIngrese el nombre de un objeto: "
success:.asciiz "La operación se realizo con exito\n\n"
greater_symbol: .asciiz ">"
invalid_option: .asciiz "\nOpción inválida. Inténtelo de nuevo.\n"

.text
main:
    la $t0, schedv
    la $t1, newcategory
    sw $t1, 0($t0)              # Opción 1: Nueva categoría

    la $t1, nextcategory
    sw $t1, 4($t0)              # Opción 2: Siguiente categoría

    la $t1, prevcategory
    sw $t1, 8($t0)              # Opción 3: Categoría anterior

    la $t1, listcategories
    sw $t1, 12($t0)             # Opción 4: Listar categorías

    la $t1, delcategory
    sw $t1, 16($t0)             # Opción 5: Borrar categoría

    la $t1, newobject
    sw $t1, 20($t0)             # Opción 6: Añadir objeto

    la $t1, listobjects
    sw $t1, 24($t0)             # Opción 7: Listar objetos

    la $t1, delobject
    sw $t1, 28($t0)             # Opción 8: Borrar objeto

menu_loop:
    # Mostrar el menú
    la $a0, menu
    li $v0, 4
    syscall

    # Leer opción del usuario
    li $v0, 5
    syscall
    move $t2, $v0              # Guardar opción en $t2

    # Verificar rango de opción válida (1-8)
    beqz $t2, exit
    li $t3, 1
    blt $t2, $t3, invalid_option_label
    li $t3, 8
    bgt $t2, $t3, invalid_option_label

    # Calcular la posición en schedv (opción - 1) * 4
    subi $t2, $t2, 1 
    sll $t2, $t2, 2
    la $t0, schedv
    add $t0, $t0, $t2  # $t0 ahora tiene la dirección de la función en schedv

    # Llamar a la subrutina a través de la dirección en $t0
    lw $t1, 0($t0)
    #move $t1, $ra
    jalr $t1                 # Saltar a la subrutina correspondiente

    # Regresar al bucle del menú después de ejecutar la opción
    j menu_loop

invalid_option_label:
    # Mensaje de opción inválida
    la $a0, invalid_option
    li $v0, 4
    syscall
    j menu_loop                # Regresar al menú

newcategory:
	addiu $sp, $sp, -4 #reserva word en stack
	sw $ra, 4($sp)	   #	
	la $a0, catName    # input category name, en el argumento $a0 para poder imprimirlo
	jal getblock
	move $a2, $v0 # $a2 = *char to category name
	la $a0, cclist # $a0 = list
	li $a1, 0 # $a1 = NULL
	jal addnode
	lw $t0, wclist
	bnez $t0, newcategory_end
	sw $v0, wclist # update working list if was NULL
newcategory_end:
	li $v0, 0 # return success
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra
nextcategory:
    addiu $sp, $sp, -4
    sw $ra, 4($sp)

    lw $t0, cclist
    beqz $t0, error_201

    lw $t1, wclist
    lw $t2, 12($t1)
    beq $t1, $t2, error_202

    sw $t2, wclist
    lw $a0, 8($t2)
    li $v0, 4
    syscall
    li $v0, 0
    j nextcategory_end
error_201:
    la $a0, error
    syscall
    li $v0, 201
    j nextcategory_end
error_202:
    la $a0, error
    syscall
    li $v0, 202
nextcategory_end:
    lw $ra, 4($sp)
    addiu $sp, $sp, 4
    jr $ra
    
prevcategory:
    # Verificar si cclist está vacío
    lw $t0, cclist        # Cargar la lista de categorías
    beqz $t0, error_201   # Si cclist es NULL, no hay categorías (error 201)

    # Verificar si hay solo una categoría (circular)
    lw $t1, wclist
    lw $t2, 0($t1)
    beq $t1, $t2, error_202
    #lw $t1, 0($t0)        # Cargar el siguiente nodo de la primera categoría
    #beq $t1, $t0, error_202 # Si el siguiente es igual al primero, hay solo una categoría (error 202)
    # Mover al nodo anterior
    # Cargar el nodo anterior de la categoría seleccionada
    sw $t2, wclist
    # Actualizar el puntero a la categoría seleccionada
    # Imprimir la categoría seleccionada
    lw $a0, 8($t2)
    li $v0, 4
    syscall              # Imprimir mensaje
    #move $a0, $t2       # Cargar el nombre de la categoría seleccionada (desde el nodo)
    #syscall             # Imprimir el nombre de la categoría seleccionada
    jr $ra               # Volver

listcategories:
    lw $t0, cclist
    beqz $t0, list_error_301
    lw $t2, wclist
    move $t1, $t0
       
list_loop:
    bne $t1, $t2, list_loop2
print_symbol:
    la $a0, greater_symbol
    syscall
list_loop2:
    lw $a0, 8($t1)
    li $v0, 4
    syscall
    lw $t1, 12($t1)
    bne $t1, $t0, list_loop

listcategories_end:
    jr $ra

list_error_301:
    li $v0, 301
    j listcategories_end
    
    
delcategory:
    addiu $sp, $sp, -4 #reserva word en stack
    sw $ra, 4($sp)
    lw $t0, wclist
    beqz $t0, error_401

    lw $t1, 4($t0)   # Lista de objetos en la categoría
    beqz $t1, delcat_no_objs

    move $a0, $t1
    jal delobject_all  # Llama a una función que borra todos los objetos

delcat_no_objs:
    lw $a0, wclist
    lw $a1, cclist
    addiu $t5, $a0, 12
    sw $t5, wclist
    jal delnode
    lw $ra, 4($sp)
    addiu $sp, $sp, 4
    jr $ra

error_401:
    li $v0, 401
    jr $ra
    
newobject:
    addiu $sp, $sp, -4 #reserva word en stack
    sw $ra, 4($sp)
    lw $t0, cclist
    beqz $t0, error_501

    # Obtener nombre del objeto
    la $a0, objName
    jal getblock
    move $a2, $v0
    lw $t0, wclist
    addi $t0, $t0, 4
    move $a0, $t0
    lw $t5, ($a0)
   bnez  $t5, otherobject
    li   $a1, 1
    jal addnode
    j   newobject_exit
    
otherobject:
    lw $t4, ($t5)
    lw $t5, 4($t4)
    addiu $a1, $t5, 1
    jal addnode

newobject_exit:
    li $v0, 0
    lw $ra, 4($sp)
    addiu $sp, $sp, 4
    jr $ra

error_501:
    li $v0, 501
    jr $ra
    
    
listobjects:
    lw $t0, wclist
    beqz $t0, error_601

    lw $t1, 4($t0)
    beqz $t1, error_602

    move $t2, $t1
list_objects_loop:
    lw $a0, 8($t2)
    li $v0, 4
    syscall
    lw $t2, 12($t2)
    bne $t2, $t1, list_objects_loop

    li $v0, 0
    jr $ra

error_601:
    li $v0, 601
    jr $ra

error_602:
    li $v0, 602
    jr $ra
delobject_all:
    # Verificar si hay objetos en la categoría seleccionada
    lw $t0, wclist            # Cargar el puntero a la categoría seleccionada
    lw $t1, 0($t0)            # Cargar el puntero al primer objeto de la categoría
    beqz $t1, error_602       # Si no hay objetos, informar el error (602)

    # Recorrer la lista de objetos
delobject_loop:
    lw $t2, 0($t1)            # Cargar el puntero al siguiente objeto
    lw $t3, 12($t1)           # Cargar el puntero al objeto anterior (para actualizar los punteros)
    
    # Eliminar el objeto actual
    jal sfree                 # Liberar el bloque de memoria del objeto

    # Actualizar punteros de la lista de objetos
    sw $t2, 0($t3)            # Establecer el siguiente puntero del objeto anterior
    sw $t3, 12($t2)           # Establecer el anterior puntero del objeto siguiente
    
    # Si hemos llegado al final de la lista (círculo completo)
    beq $t2, $t1, delobject_end # Si el siguiente es el primero, terminamos

    # Continuar con el siguiente objeto
    move $t1, $t2
    j delobject_loop

delobject_end:
    # Actualizar la lista de objetos de la categoría seleccionada para que sea NULL
    sw $zero, 0($t0)           # Establecer la lista de objetos a NULL
    li $v0, 0  
    lw $ra, 4($sp)
    addiu $sp, $sp, 4                # Indicar que la operación fue exitosa
    jr $ra

 
    
delobject:
    addiu $sp, $sp, -4 #reserva word en stack
    sw $ra, 4($sp)
    lw $t0, wclist
    beqz $t0, error_701

    li $t1, 1      # ID buscado
    lw $t2, 4($t0) # Primer objeto
delobj_loop:
    beq $t1, $a0, delobj_found
    lw $t2, 12($t2)
    bne $t2, $zero, delobj_loop

    li $v0, 0      # Not found
    lw $ra, 4($sp)
    addiu $sp, $sp, 4
    jr $ra

delobj_found:
    jal delnode
    lw $ra, 4($sp)
    addiu $sp, $sp, 4
    jr $ra

error_701:
    li $v0, 701
    jr $ra
    
# a0: list address
# a1: NULL if category, node address if object
# v0: node address added
addnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	jal smalloc
	sw $a1, 4($v0) # set node content
	sw $a2, 8($v0)
	lw $a0, 4($sp)
	lw $t0, ($a0) # first node address
	beqz $t0, addnode_empty_list
addnode_to_end:
	lw $t1, ($t0) # last node address
	# update prev and next pointers of new node
	sw $t1, 0($v0)
	sw $t0, 12($v0)
	# updat	e prev and first node to new node
	sw $v0, 12($t1)
	sw $v0, 0($t0)
	j addnode_exit
addnode_empty_list:
	sw $v0, ($a0)
	sw $v0, 0($v0)
	sw $v0, 12($v0)
addnode_exit:
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra
# a0: node address to delete
# a1: list address where node is deleted
delnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	lw $a0, 8($a0) # get block address
	jal sfree # free block
	lw $a0, 4($sp) # restore argument a0
	lw $t0, 12($a0) # get address to next node of a0
node:
	beq $a0, $t0, delnode_point_self
	lw $t1, 0($a0) # get address to prev node
	sw $t1, 0($t0)
	sw $t0, 12($t1)
	lw $t1, 0($a1) # get address to first node
again:
	bne $a0, $t1, delnode_exit
	sw $t0, ($a1) # list point to next node
	j delnode_exit
delnode_point_self:
	sw $zero, ($a1) # only one node
delnode_exit:
	jal sfree
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra

# a0: msg to ask
# v0: block address allocated with string
getblock:
	addi $sp, $sp, -4
	sw $ra, 4($sp) #guarda en stack el ra de new category
	li $v0, 4
	syscall	
	jal smalloc
	move $a0, $v0 # guarda en a0 la direccion de heap + 16 bytes
	li $a1, 16
	li $v0, 8
	syscall
	move $v0, $a0
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	 
smalloc:
	lw $t0, slist
	beqz $t0, sbrk
	move $v0, $t0
	lw $t0, 12($t0)
	sw $t0, slist
	jr $ra
sbrk:
	li $a0, 16 # node size fixed 4 words
	li $v0, 9  # llamo al heap reservando 16 bytes / 4 words
	syscall # return node address in v0
	jr $ra
sfree:
	lw $t0, slist
	sw $t0, 12($a0)
	sw $a0, slist # $a0 node address in unused list
	jr $ra
	
exit:
	li $v0, 10
	syscall
