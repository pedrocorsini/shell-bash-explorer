#!/bin/bash

directory() {
	local input
	
	input=$(dialog --stdout --inputbox "Type the directory name:" 0 0)
	if [ $? -ne 0 ] || [ -z "$input" ]; then
		dialog --msgbox "Empty input. Cancelled operation." 0 0
		return 1
	fi

	# Verifica se já existe
	if [ -d "$input" ]; then
		dialog --msgbox "Directory '$input' already exists!" 0 0
		return 1
	elif [ -f "$input" ]; then
		dialog --msgbox "A file with this name already exists: ('$input')." 0 0
		return 1
	fi
	
	if mkdir -p "$input"; then
		dialog --msgbox "Directory '$input' created with sucess!" 0 0
	else
		dialog --msgbox "Error creating directory: '$input'." 0 0
	fi
}

create_file() {
	local input
	
	input=$(dialog --stdout --inputbox "Type the file name:" 0 0)
	if [ $? -ne 0 ] || [ -z "$input" ]; then
		dialog --msgbox "Empty input. Cancelled operation." 0 0
		return 1
	fi

	if [ -f "$input" ]; then
		dialog --msgbox "File '$input' already exists!" 0 0
		return 1
	elif [ -d "$input" ]; then
		dialog --msgbox "A directory with this name already exists: ('$input')." 0 0
		return 1
	fi
	
	if touch "$input"; then
		dialog --msgbox "File '$input' sucessfully created" 0 0
	else
		dialog --msgbox "Error creating file '$input'." 0 0
	fi
}

permission(){
	while true; do
		option=$(
			dialog  --stdout \
				--title 'Permissions Menu' \
				--menu 'Choose an option:' \
				0 0 0 \
				1 "Only Read" \
				2 "Execute" \
				3 "Customized" \
				0 'Voltar')
		[ $? -ne 0 ] && return
		case "$option" in
			1) read_perm ;;
			2) execute ;;
			3) customized ;;
			*) return ;;
		esac			
	done
}

read_perm() {
	local input

	input=$(dialog --stdout --inputbox "Type the file name:" 0 0)
	if [ $? -ne 0 ] || [ -z "$input" ]; then
		dialog --msgbox "Empty input. Cancelled operation." 0 0
		return 1
	fi

	if [ ! -e "$input" ]; then
		dialog --msgbox "File'$input' does not exist." 0 0
		return 1
	fi

	if chmod a-w "$input"; then
		dialog --msgbox "File '$input' permissions changed to ONLY READ." 0 0
	else
		dialog --msgbox "Error changing filee permissions." 0 0
	fi
}

execute() {
	local input

	input=$(dialog --stdout --inputbox "Type the file name:" 0 0)
	if [ $? -ne 0 ] || [ -z "$input" ]; then
		dialog --msgbox "Empty input. Cancelled operation." 0 0
		return 1
	fi

	if [ ! -e "$input" ]; then
		dialog --msgbox "File '$input' does not exist." 0 0
		return 1
	fi

	if chmod +x "$input"; then
		dialog --msgbox "File '$input' now has EXECUTE permission." 0 0
	else
		dialog --msgbox "Error changing file permissions." 0 0
	fi
}

customized() {
	local input perm

	input=$(dialog --stdout --inputbox "Type file/directory name:" 0 0)
	[ $? -ne 0 ] && return
	[ -z "$input" ] && dialog --msgbox "Empty input." 0 0 && return

	if [ ! -e "$input" ]; then
		dialog --msgbox "File or directory does not exist." 0 0
		return
	fi

	perm=$(dialog --stdout --inputbox "Type the permission (ex: 755):" 0 0)
	[ $? -ne 0 ] && return

	if chmod "$perm" "$input"; then
		dialog --msgbox "Permission changed with sucess to '$input'." 0 0
	else
		dialog --msgbox "Error changing permissions." 0 0
	fi
}

move_file(){ 
	local origin destination 
	
	file=$(ls)
	path=$(pwd)
	dialog --msgbox "Files list in directory: '$path' \n\n'$file'" 0 0
	
	origin=$(dialog --stdout --inputbox "Type the file path to be moven:" 0 0) 
	[ $? -ne 0 ] && return 
	[ -z "$origin" ] && dialog --msgbox "Empty input." 0 0 && return 
	
	if [ ! -e "$origin" ]; then 
		dialog --msgbox "File does not exist." 0 0 
		return 
	fi 
	
	destination=$(dialog --stdout --inputbox "Type the new path:" 0 0) 
	[ $? -ne 0 ] && return 
	[ -z "$destination" ] && dialog --msgbox "Empty input." 0 0 && return 
	if [ ! -e "$destination" ]; then 
		dialog --msgbox "Directory does not exist." 0 0 
		return 
	fi 
	
	if mv "$origin" "$destination"; then 
		dialog --msgbox "File '$origin' moved to '$destination'." 0 0 
	else 
		dialog --msgbox "Error moving file." 0 0 
	fi 
}

date() {
	datahora=$(date)
    	dialog --title "Data e Hora Atual" --msgbox "$datahora" 0 0
}

change_date_time() {
    local option new_date new_time

    option=$(dialog --stdout --menu "What do you want to change?" 0 0 0 \
        1 "Change only date;" \
        2 "Change only time.")
    
    [ $? -ne 0 ] && return 

    case $option in
        1)  
            new_date=$(dialog --stdout --inputbox "Type the new date in format: 'AAAA-MM-DD':" 0 0)
            [ $? -ne 0 ] && return
            [ -z "$new_date" ] && dialog --msgbox "Empty input. Cancelled operation." 0 0 && return

            if sudo date -s "$new_date"; then
                dialog --msgbox "Date sucessfully changed to '$new_date'." 0 0
            else
                dialog --msgbox "Error changing date. Verify root permission!" 0 0
            fi
            ;;
        2)  
            new_time=$(dialog --stdout --inputbox "Type the new time in format: 'HH:MM:SS':" 0 0)
            [ $? -ne 0 ] && return
            [ -z "$new_time" ] && dialog --msgbox "Empty input. Cancelled operation." 0 0 && return

            if sudo date -s "$new_time"; then
                dialog --msgbox "Time successfully changed to '$new_time'." 0 0
            else
                dialog --msgbox "Error changing time. Verify root permission." 0 0
            fi
            ;;
    esac
}

fill_file() {
    local option file content command

    file=$(dialog --stdout --inputbox "Type file name too create/change:" 0 0)
    [ $? -ne 0 ] && return
    [ -z "$file" ] && dialog --msgbox "Empty input. Cancelled operation." 0 0 && return

    option=$(dialog --stdout --menu "How do you want to fill the file?" 0 0 0 \
        1 "With text" \
        2 "With command output")
    [ $? -ne 0 ] && return

    case $option in
        1)  
            content=$(dialog --stdout --inputbox "Type the text to the file" 0 0)
            [ $? -ne 0 ] && return
            echo "$content" > "$file"
            dialog --msgbox "File '$file' filled with success." 0 0
            ;;
        2)  
            command=$(dialog --stdout --inputbox "Type the command (ex: ps, top -b -n1, ls, free):" 0 0)
            [ $? -ne 0 ] && return
            if [ -n "$command" ]; then
                bash -c "$command" > "$file" 2>/dev/null
                dialog --msgbox "File '$file' filled with output command." 0 0
            else
                dialog --msgbox "Empty input. Cancelled operation." 0 0
            fi
            ;;
    esac
}


main_title(){
	while true; do
	    answer=$(
	      dialog \
	      	     --stdout               \
	      	     --colors \
		     --title '\Z4Files Explorer\Zn'  \
		     --menu 'Choose an option:' \
		    0 0 0 		\
		    1 "Create directory" \
		    2 "Create file" \
		    3 "Change permissions of file/directory" \
		    4 "Move file" \
		    5 "Fill file" \
		    6 "Show system date/time" \
		    7 "Change system date/time" \
		    0 'Leave'                )

	    [ $? -ne 0 ] && clear && break 

	    case "$answer" in
		 1) 	diretorio ;;
		 2) 	create_file ;;
		 3) 	permissao ;;
		 4) 	move_file ;;
		 5)	fill_file ;;
		 6)	date ;;
		 7) 	change_date_time ;;
		 0) 	clear 
		 	break ;;
	    esac

	done
}

main_title
clear
