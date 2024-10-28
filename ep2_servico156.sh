##################################################################
# MAC0216 - Técnicas de Programação I (2024)
# EP2 - Programação em Bash
#
# Nome do(a) aluno(a) 1: João Pedro Calenzani Marinho
# NUSP 1: 15463314
#
# Nome do(a) aluno(a) 2: Bernardo Pereira Silva
# NUSP 2: 15509206
##################################################################

#!/bin/bash

function selecionar_arquivo {
    echo "Escolha uma opção de arquivo:"
    select arquivocsv in $(basename -a "$diretorio_dados"/*.csv); do
        # confere se a opção existe, caso não, volta para o menu
        if [ -n "$arquivocsv" ]; then 
            arquivo_atual="$arquivocsv"
            caminho_arquivo_atual="$diretorio_dados/$arquivo_atual"
            # conta a quantidade de linhas do arquivo_atual (número de reclamações)
            numero_reclamacoes=$(cat $caminho_arquivo_atual | tail -n +2 | wc -l )
            
            echo "+++ Arquivo atual: $arquivocsv"
            echo "+++ Número de reclamações: $numero_reclamacoes"
            echo "+++++++++++++++++++++++++++++++++++++++"
            echo ""
        fi
        break
    done
    # reseta o vetor_filtros
    declare -A vetor_filtro=()
}

function adicionar_filtro_coluna {
    colunas=$(head -n 1 $caminho_arquivo_atual)
    # altera separador do select (de " " para ";")
    IFS=";"

    echo "Escolha uma opção de coluna para o filtro:"
    select coluna in $colunas; do
        # pega o índice da coluna que se deseja filtrar
        local indice_coluna=$(head -n 1 $caminho_arquivo_atual | tr ";" '\n' | nl | grep $coluna | awk '{print $1}')
        # remove todas as colunas da linha, exceto a coluna a ser filtrada, depois retorna apenas os valores únicos dessas linhas (dessa coluna)
        local categorias="$(cut -d';' -f"$indice_coluna" $caminho_arquivo_atual | tail -n +2 | sort | uniq)"
        # altera separador do select (de ";" para quebra de linha)
        IFS=$'\n'
        
        echo "Escolha uma opção de valor para $coluna:"
        select categoria in $categorias; do
            # criar vetor
            filtrar
            echo "+++ Adicionado filtro: $coluna = $categoria"
            echo "+++ Arquivo atual: $arquivo_atual"
            echo "+++ Número de reclamações: $numero_reclamacoes"
            echo "+++++++++++++++++++++++++++++++++++++++"
            echo ""
            break
        done

        break
    done
    # restaura o separador do select para o padrão (de "\n" para " ")
    IFS=" "
}

function limpar_filtros_colunas {
    # atualiza o número de reclamações
    numero_reclamacoes=$(cat "$diretorio_dados/$arquivo_atual" | tail -n +2 | wc -l )
    
    echo "+++ Filtros removidos"
    echo "+++ Arquivo atual: $arquivo_atual"
    echo "+++ Número de reclamações: $numero_reclamacoes"
    echo "+++++++++++++++++++++++++++++++++++++++"
    echo ""

    # limpa o vetor que armazena os filtros
    declare -A vetor_filtros=()
}

# vetor global que guarda os filtros
declare -A vetor_filtros=()
# variável global que guarda o conteúdo filtrado
conteudo_filtrado=""
function filtrar {
    conteudo_filtrado=$(cat "$caminho_arquivo_atual")
    for nome_coluna in "${!vetor_filtros[@]}"; do
        conteudo_filtrado=$(echo "$conteudo_filtrado" | grep "${vetor_filtros[$nome_coluna]}")
    done 
    numero_reclamacoes=$(echo "$conteudo_filtrado" | wc -l )
}

function mostrar_reclamacoes {
    echo "$conteudo_filtrado"
    echo "+++ Arquivo atual: $arquivo_atual"
    echo "+++ Filtros atuais:"
    local string_filtros=""
    local primeiro=true
    for nome_coluna in "${!vetor_filtros[@]}"; do
        if [ $primeiro == true ]; then
            string_filtros+="$nome_coluna = ${vetor_filtros[$nome_coluna]}"
            primeiro=false
        else 
            string_filtros+=" | $nome_coluna = ${vetor_filtros[$nome_coluna]}"
        fi
        
    done
    echo "$string_filtros"
    echo "+++ Número de reclamações: $numero_reclamacoes"
    echo "+++++++++++++++++++++++++++++++++++++++"
    echo ""
}

## INÍCIO DO PROGRAMA ##

# impressão de início do programa
echo "+++++++++++++++++++++++++++++++++++++++"
echo "Este programa mostra estatísticas do"
echo "Serviço 156 da Prefeitura de São Paulo"
echo "+++++++++++++++++++++++++++++++++++++++"
echo ""


diretorio_dados="dados"

## MODO DE INICIALIZAÇÃO I ##

if [ $# -gt 0 ]; then
    # parâmetro com o arquivo das urls
    urls_txt="$1"     

    # verificação da existência do arquivo
    if [ ! -f "$urls_txt" ]; then
        echo "ERRO: O arquivo $urls_txt não existe."
        exit 1
    else

        ## ETAPA DE DOWNLOAD E CRIAÇÂO DA PASTA DADOS ##

        # criação do diretorio que armazenará os arquivos csv
        mkdir -p $diretorio_dados

        # guarda a data do começo do download no formato desejado
        tempo_inicial=$( date +"%Y-%m-%d %H:%M:%S" )
        echo "$tempo_inicial"
        # percorre o arquivo .txt e captura as urls
        for url in $( cat "$urls_txt"); do
            # remove "%0D" do final da linha se tiver
            url=$(echo "$url" | tr -d '\r')
            # baixa o arquivo da url
            wget -nv "$url" -P "$diretorio_dados"
        done 

        # guarda a data de encerramento do download
        tempo_final=$( date +"%Y-%m-%d %H:%M:%S" )

        # comando para contar as linhas do ls na pasta de dados, indicando o número de arquivos baixados
        quantidade_arquivos=$(ls "$diretorio_dados" | wc -l)
        # comando para capturar a memória utilizda pela pasta criada, equivalente ao total baixado
        tamanho_arquivos=$(du -b "$diretorio_dados" | grep "." | awk '{print $1}')
        tamanho_mb=$(echo "$tamanho_arquivos / 1048576" | bc)

        # opera uma subtração entre as duas datas armazenadas anteriormente, fazendo a diferença em segundos
        periodo=$(($(date -ud "$tempo_final" +%s) - $(date -ud "$tempo_inicial" +%s)))
        # calcula a velocidade de download dividindo o tamanho pelo tempo
        velocidade_download=$(echo "$tamanho_mb / $periodo" | bc)
        
        # realiza as impressões finais de download
        echo "FINALIZADO --$tempo_final--"
        echo "Tempo total decorrido: $(date -ud "@$periodo" +'%Mm %Ss')"
        echo "Baixados: $quantidade_arquivos, $tamanho_mb"M" em $(date -ud "@$periodo" +'%Mm %Ss') ($velocidade_download MB/s) "
        echo ""


        ## MODIFICAÇÃO DOS ARQUIVOS E CRIAÇÃO DO ARQUIVOCOMPLETO.CSV ##

        # loop que modifica para UTF8 os arquivos csv
        for arquivocsv in "$diretorio_dados"/*.csv; do
            iconv -f ISO-8859-1 -t UTF-8 "$arquivocsv" -o "$arquivocsv.temp" && mv "$arquivocsv.temp" "$arquivocsv"
        done

        # definindo o caminho para o arquivo que concatenará todos
        arquivocompletocsv="$diretorio_dados/arquivocompleto.csv"

        # passando entrada vazia para criar o arquivo sem nada
        > "$arquivocompletocsv"


        # loop que coloca o conteúdo dos arquivos de dados em arquivocompleto.csv
        for arquivocsv in "$diretorio_dados"/*.csv; do
            # o primeiro arquivo é incluido com o cabeçalho, os outros tem seu cabeçalho retirado
            if [ "$arquivocsv" == "$(ls "$diretorio_dados"/*.csv | tail -n +2 | head -n 1)" ]; then
                cat "$arquivocsv" >> "$arquivocompletocsv"
            else
                tail -n +2 "$arquivocsv" >> "$arquivocompletocsv"
            fi

        done

    fi



## MODO DE INICIALIZAÇÃO II ##

else 
    # verificação se existe o diretório dados e se ele possui realmente algum arquivo
    if [ ! -d "$diretorio_dados" ] || [  $(ls $diretorio_dados | wc -l) -eq 0 ]; then 
        # mensagem de erro com encerramento do processo
        echo "ERRO: Não há dados baixados."
        echo "Para baixar os dados antes de gerar as estatísticas, use:"
        echo "   ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    exit 1
    fi
fi


## SISTEMA DE MENUS COM FLUXO CONTÍNUO ##

## VARIÁVEIS IMPORTANTES DO PROGRAMA ##

# variável de estado do programa, para criar que se saiba qual será a próxima etapa do programa
estado="menu"
# menu que será usado em um comando select, corpo do menu padrão
menu_inicial="selecionar_arquivo adicionar_filtro_coluna limpar_filtros_colunas mostrar_duracao_media_reclamacao mostrar_ranking_reclamacoes mostrar_reclamacoes sair"
# variável que define arquivo atual selecionado, tendo como padrão o arquivo completo
arquivo_atual="arquivocompleto.csv"
# variável que representa o caminho do arquivo atual selecionado
caminho_arquivo_atual="$diretorio_dados/$arquivo_atual"

# while que só termina com break ou pelo comando de saída
while true; do 
    if [ "$estado" == "menu" ]; then
        echo "Escolha uma opção de operação:"

        select opcao in $menu_inicial; do
            echo ""
            if [ "$opcao" == "sair" ]; then
                echo 'Fim do programa'
                echo "+++++++++++++++++++++++++++++++++++++++"
                
                exit 1
            elif [ "$opcao" == "selecionar_arquivo" ]; then
                selecionar_arquivo
                break
            elif [ "$opcao" == "adicionar_filtro_coluna" ]; then
                adicionar_filtro_coluna
                break
            elif [ "$opcao" == "limpar_filtros_colunas" ]; then
                limpar_filtros_colunas
                break
            fi
        done
    fi

done

exit 1