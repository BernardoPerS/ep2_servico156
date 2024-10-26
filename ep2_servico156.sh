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

echo "+++++++++++++++++++++++++++++++++++++++"
echo "Este programa mostra estatísticas do"
echo "Serviço 156 da Prefeitura de São Paulo"
echo "+++++++++++++++++++++++++++++++++++++++"


diretorio_dados="dados"

# modo de inicialização i)
if [ $# -gt 0 ]; then
    # parâmetro com o arquivo das urls
    urls_txt="$1"     

    # verificação da existência do arquivo
    if [ ! -f "$urls_txt" ]; then
        echo "ERRO: O arquivo $urls_txt não existe."
        exit 1
    else
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

        velocidade_download=$(echo "$tamanho_mb / $periodo" | bc)
        
        echo "FINALIZADO --$tempo_final--"
        echo "Tempo total decorrido: $(date -ud "@$periodo" +'%Mm %Ss')"
        echo "Baixados: $quantidade_arquivos, $tamanho_mb"M" em $(date -ud "@$periodo" +'%Mm %Ss') ($velocidade_download MB/s) "

    fi


else 
    if [ ! -d "$diretorio_dados" ]; then 
        echo "ERRO: Não há dados baixados."
        echo "Para baixar os dados antes de gerar as estatísticas, use:"
        echo "   ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    exit 1
    fi
fi









exit 1




