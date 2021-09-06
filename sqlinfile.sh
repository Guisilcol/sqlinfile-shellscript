#############################################
# CSV to SQL - Executa um commando SQL dentro de um arquivo com dados
# È criada uma tabela em memória usando SQLITE3 que será referenciada como "foo", e cada coluna varia de c1 até cn (onde n é o número máximo de colunas informada)
# 
# Requisitos: sqlite3 instalado na maquina
#
# Argumentos: 
# $1 -> Diretorio do arquivo que será convertido em tabela
# $2 -> Quantidade de campos presentes no arquivo
# $3 -> Quantidade de linhas iniciais que serão ignoradas (SEMPRE PULAR O HEADER DO ARQUIVO CASO TENHA)
# $4 -> Query que será executada 
# $5 -> Delimitador de colunas do arquivo
#
# Exemplo de uso: sh /dw/COMISSIONAMENTO/STAGE/sqlincsv.sh "/dw/COMISSIONAMENTO/STAGE/FF_BI_AUX_EQUIPAMENTO.TXT" 12 0 "select c1, c2 from foo limit 10" "|"
#############################################

file_directory=$1
field_quantity=$2
skip_rows=$3
sql_query=$4
field_separator=$5

aux_file_directory="${file_directory}.aux"

# Copia o arquivo pulando a quantidade de linhas iniciais informadas 

tail -n +$(($skip_rows + 1)) $file_directory > $aux_file_directory

# Cria a string para criação da tabela temporaria 

sql_field_string=""

for i in $(seq 1 $field_quantity)
do 
    if [ $i = 1 ]; then 
        sql_field_string="c${i}"
    else 
        sql_field_string="${sql_field_string}, c${i}"
    fi
done

sqlite3 << commands 

CREATE TABLE foo($sql_field_string);
.mode csv
.separator "$field_separator"
.import $aux_file_directory foo
.header on
.separator "|"
$sql_query;

commands

rm $aux_file_directory