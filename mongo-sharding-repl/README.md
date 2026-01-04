# mongo-sharding

## Как запустить

Запускаем приложение и контейнеры mongodb

```shell
docker compose up -d
```

Конфигурируем шарды mongodb и заполняем их данными
```shell
./scripts/mongo-init.sh
```

## Как проверить

Откройте в браузере http://localhost:8080