#!/bin/bash
MYSQL_USER="root"

# Получение пароля
if [ -n "$1" ]; then
    MYSQL_PASSWORD="$1"
else
    read -rsp "Введите пароль MySQL root: " MYSQL_PASSWORD
    echo
fi

# Создание временного файла конфигурации
MY_INI=$(mktemp /tmp/mysql_config_XXXXXX.ini)

cat > "$MY_INI" <<EOF
[client]
user=$MYSQL_USER
password="$MYSQL_PASSWORD"
EOF

# Удаление временного файла при выходе или ошибке
trap 'rm -f "$MY_INI"' EXIT

MYSQL="mysql --defaults-extra-file=$MY_INI -t"

echo "=== Запуск баз данных ==="

for D in db_1_transport db_2_racing db_3_booking db_4_organization_structure; do
    echo
    echo "--- Инициализация $D ---"
    $MYSQL < "$D/schema.sql"
    $MYSQL < "$D/data.sql"
    echo "--- Запросы $D ---"
    $MYSQL < "$D/queries.sql"
done

echo
echo "=== Конец ==="