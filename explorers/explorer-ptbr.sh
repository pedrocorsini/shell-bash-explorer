#!/bin/bash
# Exemplo de menu com o dialog

diretorio() {
	local entrada
	
	entrada=$(dialog --stdout --inputbox "Digite o nome do diretório:" 0 0)
	if [ $? -ne 0 ] || [ -z "$entrada" ]; then
		dialog --msgbox "Operação cancelada ou nome vazio." 0 0
		return 1
	fi

	# Verifica se já existe
	if [ -d "$entrada" ]; then
		dialog --msgbox "O diretório '$entrada' já existe!" 0 0
		return 1
	elif [ -f "$entrada" ]; then
		dialog --msgbox "Já existe um ARQUIVO com esse nome ('$entrada')." 0 0
		return 1
	fi
	
	if mkdir -p "$entrada"; then
		dialog --msgbox "Diretório '$entrada' criado com sucesso!" 0 0
	else
		dialog --msgbox "Erro ao criar o diretório '$entrada'." 0 0
	fi
}

arquivo() {
	local entrada
	
	entrada=$(dialog --stdout --inputbox "Digite o nome do arquivo:" 0 0)
	if [ $? -ne 0 ] || [ -z "$entrada" ]; then
		dialog --msgbox "Operação cancelada ou nome vazio." 0 0
		return 1
	fi

	# Verifica se já existe
	if [ -f "$entrada" ]; then
		dialog --msgbox "O arquivo '$entrada' já existe!" 0 0
		return 1
	elif [ -d "$entrada" ]; then
		dialog --msgbox "Já existe um DIRETÓRIO com esse nome ('$entrada')." 0 0
		return 1
	fi
	
	if touch "$entrada"; then
		dialog --msgbox "Arquivo '$entrada' criado com sucesso!" 0 0
	else
		dialog --msgbox "Erro ao criar o arquivo '$entrada'." 0 0
	fi
}

permissao(){
	while true; do
		opcao=$(
			dialog  --stdout \
				--title 'Menu Permissões' \
				--menu 'Escolha uma opcao:' \
				0 0 0 \
				1 "Somente leitura" \
				2 "Execução" \
				3 "Personalizável" \
				0 'Voltar')
		[ $? -ne 0 ] && return
		case "$opcao" in
			1) leitura ;;
			2) execucao ;;
			3) personalizavel ;;
			*) return ;;
		esac			
	done
}

leitura() {
	local entrada

	entrada=$(dialog --stdout --inputbox "Digite o nome do arquivo:" 0 0)
	if [ $? -ne 0 ] || [ -z "$entrada" ]; then
		dialog --msgbox "Operação cancelada ou nome vazio." 0 0
		return 1
	fi

	if [ ! -e "$entrada" ]; then
		dialog --msgbox "Arquivo '$entrada' não existe." 0 0
		return 1
	fi

	if chmod a-w "$entrada"; then
		dialog --msgbox "Permissões do arquivo '$entrada' alteradas para SOMENTE LEITURA." 0 0
	else
		dialog --msgbox "Erro ao alterar permissões do arquivo." 0 0
	fi
}

execucao() {
	local entrada

	entrada=$(dialog --stdout --inputbox "Digite o nome do arquivo:" 0 0)
	if [ $? -ne 0 ] || [ -z "$entrada" ]; then
		dialog --msgbox "Operação cancelada ou nome vazio." 0 0
		return 1
	fi

	if [ ! -e "$entrada" ]; then
		dialog --msgbox "Arquivo '$entrada' não existe." 0 0
		return 1
	fi

	if chmod +x "$entrada"; then
		dialog --msgbox "Arquivo '$entrada' agora tem permissão de EXECUÇÃO." 0 0
	else
		dialog --msgbox "Erro ao alterar permissões." 0 0
	fi
}

personalizavel() {
	local entrada perm

	entrada=$(dialog --stdout --inputbox "Digite o nome do arquivo/diretório:" 0 0)
	[ $? -ne 0 ] && return
	[ -z "$entrada" ] && dialog --msgbox "Nome vazio." 0 0 && return

	if [ ! -e "$entrada" ]; then
		dialog --msgbox "Arquivo ou diretório não existe." 0 0
		return
	fi

	perm=$(dialog --stdout --inputbox "Digite o modo de permissão (ex: 755):" 0 0)
	[ $? -ne 0 ] && return

	if chmod "$perm" "$entrada"; then
		dialog --msgbox "Permissões alteradas com sucesso para '$entrada'." 0 0
	else
		dialog --msgbox "Erro ao alterar permissões." 0 0
	fi
}

mover_arquivo(){ 
	local origem destino 
	
	arquivo=$(ls)
	caminho=$(pwd)
	dialog --msgbox "Lista de arquivos no diretorio: '$caminho' \n\n'$arquivo'" 0 0
	
	origem=$(dialog --stdout --inputbox "Digite o caminho do arquivo a ser movido:" 0 0) 
	[ $? -ne 0 ] && return 
	[ -z "$origem" ] && dialog --msgbox "Nome vazio." 0 0 && return 
	
	if [ ! -e "$origem" ]; then 
		dialog --msgbox "Arquivo não existente." 0 0 
		return 
	fi 
	
	destino=$(dialog --stdout --inputbox "Digite o novo caminho:" 0 0) 
	[ $? -ne 0 ] && return 
	[ -z "$destino" ] && dialog --msgbox "Nome vazio." 0 0 && return 
	if [ ! -e "$destino" ]; then 
		dialog --msgbox "Diretório não existente." 0 0 
		return 
	fi 
	
	if mv "$origem" "$destino"; then 
		dialog --msgbox "Arquivo '$origem' movido para '$destino'." 0 0 
	else 
		dialog --msgbox "Erro ao mover arquivo." 0 0 
	fi 
}

data() {
	datahora=$(date)
    	dialog --title "Data e Hora Atual" --msgbox "$datahora" 0 0
}

alterar_data_hora() {
    local opcao nova_data nova_hora

    # Menu de escolha
    opcao=$(dialog --stdout --menu "O que deseja alterar?" 0 0 0 \
        1 "Alterar apenas a data" \
        2 "Alterar apenas a hora")
    
    [ $? -ne 0 ] && return  # Cancelar

    case $opcao in
        1)  # Alterar apenas a data
            nova_data=$(dialog --stdout --inputbox "Digite a nova data no formato 'AAAA-MM-DD':" 0 0)
            [ $? -ne 0 ] && return
            [ -z "$nova_data" ] && dialog --msgbox "Entrada vazia. Operação cancelada." 0 0 && return

            if sudo date -s "$nova_data"; then
                dialog --msgbox "Data alterada com sucesso para '$nova_data'." 0 0
            else
                dialog --msgbox "Erro ao alterar data. Certifique-se de ter permissão de root." 0 0
            fi
            ;;
        2)  # Alterar apenas a hora
            nova_hora=$(dialog --stdout --inputbox "Digite a nova hora no formato 'HH:MM:SS':" 0 0)
            [ $? -ne 0 ] && return
            [ -z "$nova_hora" ] && dialog --msgbox "Entrada vazia. Operação cancelada." 0 0 && return

            if sudo date -s "$nova_hora"; then
                dialog --msgbox "Hora alterada com sucesso para '$nova_hora'." 0 0
            else
                dialog --msgbox "Erro ao alterar hora. Certifique-se de ter permissão de root." 0 0
            fi
            ;;
    esac
}

preencher_arquivo() {
    local opcao arquivo conteudo comando

    # Pergunta o nome do arquivo
    arquivo=$(dialog --stdout --inputbox "Digite o nome do arquivo que deseja criar/alterar:" 0 0)
    [ $? -ne 0 ] && return
    [ -z "$arquivo" ] && dialog --msgbox "Entrada vazia. Operação cancelada." 0 0 && return

    # Menu de escolha
    opcao=$(dialog --stdout --menu "Como deseja preencher o arquivo?" 0 0 0 \
        1 "Com texto" \
        2 "Com saída de comando")
    [ $? -ne 0 ] && return

    case $opcao in
        1)  # Preencher com texto
            conteudo=$(dialog --stdout --inputbox "Digite o texto para o arquivo:" 0 0)
            [ $? -ne 0 ] && return
            echo "$conteudo" > "$arquivo"
            dialog --msgbox "Arquivo '$arquivo' preenchido com sucesso." 0 0
            ;;
        2)  # Preencher com saída de comando
            comando=$(dialog --stdout --inputbox "Digite o comando (ex: ps, top -b -n1, ls, free):" 0 0)
            [ $? -ne 0 ] && return
            if [ -n "$comando" ]; then
                # Executa o comando e salva a saída no arquivo
                bash -c "$comando" > "$arquivo" 2>/dev/null
                dialog --msgbox "Arquivo '$arquivo' preenchido com a saída do comando." 0 0
            else
                dialog --msgbox "Comando vazio. Operação cancelada." 0 0
            fi
            ;;
    esac
}


menu_principal(){
	while true; do
	    resposta=$(
	      dialog \
	      	     --stdout               \
	      	     --colors \
		     --title '\Z4Explorador de Arquivos\Zn'  \
		     --menu 'Escolha uma opção:' \
		    0 0 0 		\
		    1 "Criar Diretório" \
		    2 "Criar arquivo" \
		    3 "Mudar permissoes de arquivo/diretório" \
		    4 "Mover arquivo" \
		    5 "Preencher arquivo" \
		    6 "Exibir data/hora do sistema" \
		    7 "Alterar data/hora do sistema" \
		    0 'Sair'                )

	    [ $? -ne 0 ] && clear && break 

	    case "$resposta" in
		 1) 	diretorio ;;
		 2) 	arquivo ;;
		 3) 	permissao ;;
		 4) 	mover_arquivo ;;
		 5)	preencher_arquivo ;;
		 6)	data ;;
		 7) 	alterar_data_hora ;;
		 0) 	clear 
		 	break ;;
	    esac

	done
}

menu_principal
clear
