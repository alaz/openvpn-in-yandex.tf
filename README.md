## Начало

1. Создайте сервисного пользователя
2. Заполните поля в `terraform.tvars`, либо скопируйте файл в
   `local.auto.tfvars` и заполните там, чтобы исключить загрузку Ваших данных в
   Git.
3. Получите
   [авторизованный ключ](https://yandex.cloud/ru/docs/iam/operations/authorized-key/create#tf_1).
   Это будет файл `authorized_key.json`, который надо положить сюда в корень
   проекта.
4. Запустите `$(./init.js)`.
