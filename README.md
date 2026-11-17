# imdb_lab — Back-End (Flask + MySQL), лабораторні роботи 4 та 5

REST API для бази даних imdb_lab. Шари: route, controller, service, dao, domain.

Лабораторна 5: тригери, збережені процедури, функція, курсор у MySQL та їх виклик через контролери.

## Запуск

1. У MySQL Workbench виконати app/data.sql.
2. У MySQL Workbench виконати app/lab5.sql.
3. У app/config/app.yml вказати пароль MySQL.
4. У терміналі в папці app:

```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 app.py
```

Сервер: http://localhost:5001

Postman: Import, файл app/imdb_lab.postman_collection.json, змінна base_url = http://localhost:5001
