# OpenVPN на Yandex Cloud с помощью Terraform

## Зависимости

- Deno, можно установить как `brew install deno`
- Terraform, можно установить например как `brew install tfenv`, `tfenv install`
- Создайте сервисного пользователя в Yandex Cloud
- Заполните поля в `terraform.tvars`, либо скопируйте файл в `local.auto.tfvars`
  и заполните там, чтобы исключить загрузку Ваших данных в Git.
- Получите
  [авторизованный ключ](https://yandex.cloud/ru/docs/iam/operations/authorized-key/create#tf_1).
  Это будет файл `authorized_key.json`, который надо положить сюда в корень
  проекта.

## Перед началом работы

IAM токен имеет ограниченный срок жизни. Поэтому следующее действие надо
выполнять перед началом работы:

```
$(./init.js)
```

## Создать OpenVPN сервер

```
terraform apply
```

После чего,

```
open local/<file>.pem
```

## Удалить всю созданную инфраструктуру

```
terraform destroy
```

Папка `local` тоже будет удалена.
