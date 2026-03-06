#!/bin/sh
echo "Content-type: text/html; charset=utf-8"
echo ""
echo '<!DOCTYPE html>'
echo '<html>'
echo '<head>'
echo '<meta charset="UTF-8">'
echo '<meta http-equiv="refresh" content="2;url=http://192.168.1.4:8080/cgi-bin/p/backup_manager.cgi">'
echo '</head>'
echo '<body>'
echo '<p>Перенаправление на управление бэкапами...</p>'
echo '<p><a href="http://192.168.1.4:8080/cgi-bin/p/backup_manager.cgi">Нажмите здесь, если не перенаправляет автоматически</a></p>'
echo '</body>'
echo '</html>'
