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


## INÍCIO DO PROGRAMA ##

# impressão de início do programa
echo "+++++++++++++++++++++++++++++++++++++++"
echo "Este programa mostra estatísticas do"
echo "Serviço 156 da Prefeitura de São Paulo"
echo "+++++++++++++++++++++++++++++++++++++++"


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
        for url in $( cat "$urls_txt" ); do
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
    if [ ! -d "$diretorio_dados" ] || [  $(ls $diretorio_dados | wc -l) -eq 0 ]; then 
        echo "ERRO: Não há dados baixados."
        echo "Para baixar os dados antes de gerar as estatísticas, use:"
        echo "   ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    exit 1
    fi
fi









exit 1




