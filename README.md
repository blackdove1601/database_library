# database_library

База данных "Научно-техническая библиотека" (СУБД Microsoft SQL Server 2019).

Работа выполнена в рамках курса "Базы данных" направления "Информатика и вычислительная техника", НИТУ МИСИС.

1. [Задание](#Задание)
2. [Описание структуры базы данных](#Структура)
3. [Описание представлений](#Представления)
4. [Описание функций](#Функции)
5. [Описание хранимых процедур](#Процедуры)
6. [Описание триггеров](#Триггеры)


## Задание <a name="Задание"></a>
**Задача:** разработать базу данных

**Требования:**
* Минимальное количество таблиц: 10
* Реализовать представления, функции, хранимые процедуры, триггеры для работы с созданной БД (минимальное количество объектов каждого типа – по 3)
* Реализовать возможность изменения, добавления и удаления записей, как минимум, в однопредставление (view)
* Использовать ПО, применяемое при изучении дисциплины (Microsoft SQL Server 2019)

**Предметная область: Научно-техническая библиотека**

БД должна обеспечивать:
* ведение автоматизированного учёта выдачи/приёма литературы; 
* ведение очередей на литературу (по заказам); 
* учёт рейтинга изданий (количество читателей и дата последней выдачи); 
* поиск литературы по требуемым разделу, теме, автору, ключевому слову (с заданием интересующего периода); 
* составление списков должников по годам.

## Описание структуры базы данных <a name="Структура"></a>

База данных приведена к 3 нормальной форме.

![](https://sun9-58.userapi.com/impg/JITwNNZ0M_u_uQnnYzNEE5cfrmh4j5uzmRqemQ/WH-rfTfqyjY.jpg?size=1181x921&quality=96&sign=563b35fa8ae0a97f0804abd32f223383&type=album)

* **Author** - информация об авторе
* **BookInfo** - информация об уникальных книгах
* **Book** - информация о копиях книг (IsAvailable: 1 - книга доступна для выдачи, 0 - недоступна)
* **Publisher** - информация об издательствах
* **Category** - информация о категориях 
* **Reader** - информация о читателях
* **TakenBook** - информация об актах выдачи и возврата книг (Deadline - дата возврата, OnTime: 1 - книга возвращена вовремя, 0 - с опозданием, Null - все еще не возвращена)
* **Hold** - информация об обращениях к отсутсвуюшим книгам
* **Feedback** - отзывы читателей о книгах
* **KeyWord** - ключевые слова книг для поиска

## Описание представлений <a name="Представления"></a>

### vDebtors
Содержит информацию о должниках

![](https://sun9-68.userapi.com/impg/Gr3Ljo7IuO-rbaIbxvnxoA2FtUzW1EduMC6ytA/GAfGfjJRqr0.jpg?size=614x182&quality=96&sign=81b197b9b3332028fac26c74724169c3&type=album)

### vPublicationRating
Количество обращений, дата последнего обращения, средняя оценка для каждой книги
![](https://sun9-30.userapi.com/impg/YyuJ7_6ni04lN8z9o_kKAf_pt97uo4JIwZCSfA/PcNTW5GKV34.jpg?size=1153x227&quality=96&sign=f8813c201a6fd0abc11fe9d572badb54&type=album)

### vReviews
Отзывы читателей

![](https://sun9-72.userapi.com/impg/Wj5qvnn4bOHuttixP6QAj2-N-7bCT517b9xS_A/D8DL629_ilA.jpg?size=1316x239&quality=96&sign=aa325031d5cbe19094f6a9640036f6ed&type=album)

### vNumberOfRequestsByCategory
Количество обращений по категориям

![](https://sun9-43.userapi.com/impg/mIwpJ4OifCb3sIlAOWk9cFeiCnrzY6A-0kgx3Q/yYLRKUureVI.jpg?size=489x247&quality=96&sign=7deff3612651608f5de937c7348eff8f&type=album)


## Описание функций <a name="Функции"></a>

### getAuthors
По ID книги возвращает имена всех авторов (их может быть несколько) в одной строке. 

Используется в представлении vPublicationRating

![](https://sun9-43.userapi.com/impg/1aHYRkUPqSrCwRUTS6UR8y5tsSnfyL28rQwT7Q/CsS4_gqIN88.jpg?size=447x127&quality=96&sign=251a27f6c42f141cead677f714249355&type=album)

### getNumberOfReaders
По ID книги возвращает количество обращений к книге. 

Используется в представлении vPublicationRating

![](https://sun9-84.userapi.com/impg/iCc39xqo024bSlPrVYjkdhxtKL6_xz79Jjcc-Q/X2AvuyaFW6Q.jpg?size=457x116&quality=96&sign=c85456da232596bb1aad15062e1d9cd4&type=album)

### getLastTakenDate
По ID книги возвращает дату последнего обращения

Используется в представлении vPublicationRating

![](https://sun9-51.userapi.com/impg/OufTwHpbfnUhDcuuaiDbizsbj0dFc4DVkrprcQ/RaPK7xh1ju8.jpg?size=379x122&quality=96&sign=dacafa95b23f10e063de78276a4e9247&type=album)


### getBookRaiting

По ID книги возвращает среднюю оценку читателей

Используется в представлении vPublicationRating

![](https://sun9-30.userapi.com/impg/xJ_4H493uG0QE3VMQUf__fKV5axpjeIZJA4kfw/EUzIpR9zees.jpg?size=418x120&quality=96&sign=3704ceed3cb1e01b21e3a36ad7832e5f&type=album)

### BookQueue

По ID автора возвращает список очередей на каждую его книгу

![](https://sun9-70.userapi.com/impg/5uaubkJ54d4mEg0cOuwVeUdyAtKeNU4mtzPIgQ/M6UuGE0HyA0.jpg?size=773x265&quality=96&sign=d7fdb6adf1de5982b4a506218ad947be&type=album)

### QueueForBook

По ID книги возвращает очередь на нее

![](https://sun9-51.userapi.com/impg/63HRA6YrU2fLhmMBn2LKrMxAnn8dQJhzqZOPmg/CTZXBei7DN0.jpg?size=644x223&quality=96&sign=9143c912b211fa89d2f0c643b7538825&type=album)

### FirstReader

По ID книги возвращает первого читателя в очереди на нее

Используется в триггере HeldBookReturned 

![](https://sun9-76.userapi.com/impg/opTzTisFD3CeTqkek2IxJyn7LTUmydlMjFtSzg/99hnoZdC2B8.jpg?size=660x184&quality=96&sign=80e23eb6ae5eb46092172b339d0f7f88&type=album)

## Описание хранимых процедур <a name="Процедуры"></a>

### SearchBy

Поиск литературы по заданным параметрам: раздел, подраздел, автор, ключевое слово, начало периода, конец периода (когда книга была написана)

NULL - параметр не задан

![](https://sun9-77.userapi.com/impg/jgNxfiJxe2yIDbZS4rAZ3R_KCsYhJ8Xh0-6_7w/dYIE9GpeGMQ.jpg?size=1198x664&quality=96&sign=12df4c70cfaea914ec362890cdc84160&type=album)

### TakenForNWeeks

Выдача книги на определенное количество недель

На вход принимается читательский билет, ID книги (по таблице BookInfo), количество недель. Далее по таблице Book просиходит поиск доступных для выдачи книг. Если никаких копий в таблице нет или есть очередь на книгу, но читетель в ней не первый, то он вносится в очередь (таблица Hold) при помощи процедуры PutOnHold. Если книга есть в наличии и очередь на нее отсуствует или читатель первый в очереди, то книга выдается. В таблице TakenBook появляется запись о том, что книга была взята (в столбце OnTime NULL до тех пор, пока книга не будет возвращена). В таблице Book выданный экземпляр книги принимает значение IsAvailable = 0

### PutOnHold

Добавление читателя в очередь (по id книги и номеру читательского билета)

### TakenBack

Возврат книги

На вход принимается номер читательского билета и инвентарный номер книги (таблица Book)

Если книга возвращена вовремя, то в таблице TakenBook в нужной строке OnTime становится равным 1 (в противном случае - 0). В таблице Book возвращенный экземпляр книги принимает значение IsAvailable = 1. Если возвращена книга, на которую есть очередь, то выводятся контакты первого читателя в очереди

![](https://sun9-50.userapi.com/impg/FHtANg6zd3_gompX1-TtlJJf5tY7gmx-OKyI7g/aTusIfowv2c.jpg?size=552x196&quality=96&sign=203298098152dddd9790d778ffb81e71&type=album)

## Описание триггеров <a name="Триггеры"></a>

### HeldBookReturned 

Триггер на таблицу TakenBook. Срабатывает при возврате книги и выводит информацию о первом читателе в очереди на данную книгу

### BookWasTaken

Триггер на таблицу TakenBook. Срабатывает при возврате книги и обновляет статус о доступности книги в таблице Book

### DeleteReview, UpdateReview, InsertReview

Триггеры на представление vReviews. Срабатывают при попытке удалить, обновить или добавить отзыв в представление. В случае успеха обновляется таблица Feedback

