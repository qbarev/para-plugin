# Language: ru

Every string a skill writes into a note or prints to chat comes from this file; the
language is chosen per vault by `LANG` in `vault.md` (`paths.md` «Language»). The
English file `en.md` carries exactly the same keys.

Format: one entry per line, `key: value`. A key is lowercase, dotted, named by meaning.
Placeholders in braces (`{n}`, `{title}`) are filled by the skill. Section values are the
heading text without the leading `#`. Nothing else on a line that starts with a key.

## Note sections

project.goal: Цель
project.problem: Проблема
project.value: Ценность
project.expected_result: Ожидаемый результат
project.scope: Скоуп работ
project.dod: Критерий готовности
project.what_changed: Что изменилось
common.links: Ссылки
area.current_state: Текущее состояние
area.notes: Заметки
resource.summary: Конспект
resource.own_thoughts: Свои мысли
note.essence: Суть
note.open_questions: Открытые вопросы

## Values

resource.type.article: статья
resource.type.book: книга
resource.type.video: видео
resource.type.own_thought: своя мысль
project.outcome.completed: Завершён.
project.outcome.abandoned: Брошен: {reason}.
archive.no_outcome: без отметки
common.no_metadata: без метаданных

## Tasks

task.unpaired: нет пары в менеджере задач
task.overdue_by: просрочена на {n} дн
task.research.name: Ресерч «{short}»: определить скоуп работ
task.research.done: в заметке проекта заполнен «{scope}», по его пунктам заведены задачи
task.waiting.name: Проверить, ответил ли консультант
count.scheduled: запланировано
count.overdue: просрочено
count.backlog: в бэклоге
count.backlog_short: бэклог
count.closed: закрыто
common.unit.min: мин
common.unit.hour: ч
common.unit.day: дн
common.weekdays: ПН ВТ СР ЧТ ПТ СБ ВС

## Inbox

inbox.name: Входящие
inbox.header: **{n} во Входящих**, самой старой {days} дн
inbox.strays: В папке Inbox/ ещё {k} файлов — разберу в /inbox process
inbox.route.action: Действие
inbox.route.project_task: Задача проекта
inbox.route.project: Проект
inbox.route.area: Область
inbox.route.resource: Ресурс
inbox.route.keep: Оставить
inbox.route.delete: Удалить

## Archive

archive.list.projects: **Проекты в архиве ({n})**
archive.list.notes: **Заметки в архиве ({n})**
archive.list.deadline: дедлайн {date}
archive.ask_changed: что этот проект изменил?
archive.expected: Ожидалось: {value}. Сбылось?

## Projects

overview.area: Область
overview.deadline: Дедлайн
overview.tasks: Задачи
overview.acceptance: Приёмка
overview.essence: Суть
overview.scheduled: Запланировано
overview.backlog: Бэклог
overview.digest: Выжимка
overview.signals: Сигналы
overview.backlog_more: …и ещё {n}
overview.legacy: Старый формат: {fields} — перенести при груминге
list.header: **Проекты ({n})**
list.until: до {date} ({n} дн)
list.deadline_passed: дедлайн прошёл {n} дн назад
list.backlog_empty: бэклог пуст
list.legacy: старый формат
list.orphans: Без пары в хранилище: {names}

## Areas

areas.review.heading: Области
areas.review.group: **{group}** — заметок: {n}, последняя правка {days} дн назад
areas.review.no_notes: нет заметок
areas.review.stale: «{title}» не менялась {days} дн

## Vault lint

lint.heading: Проверка хранилища — {n} заметок
lint.group.breaks: Ломает хранилище
lint.group.schema: Нарушает схему
lint.group.review: Стоит посмотреть
lint.finding.not_configured: Хранилище не настроено
lint.finding.duplicate_names: Дубли имён файлов
lint.finding.dangling_links: Висячие вики-ссылки
lint.finding.notes_in_repo_root: Заметки в REPO_ROOT
lint.finding.extra_folders: Лишние папки в PARA_ROOT
lint.finding.inbox_files: Файлы в Inbox/
lint.finding.duplicate_ids: Дубли id
lint.finding.id_mismatch: id не совпадает с префиксом папки
lint.finding.dangling_project: Заметка указывает на несуществующий проект
lint.finding.dates: Даты
lint.finding.tag_placeholders: Плейсхолдеры тегов
lint.finding.missing_subfolders: Проект без одной из трёх подпапок
lint.finding.misplaced_fields: short или tasks_ref не на своём месте
lint.finding.pair: Пара с менеджером задач
lint.finding.legacy: Старый формат
lint.finding.sync_copies: Копии синхронизации
lint.finding.unpaired: Без пары
lint.finding.old_field_name: Старое имя поля
lint.finding.orphans: Заметки-сироты
lint.finding.no_frontmatter: Заметки без frontmatter
lint.pair_lost: пара потеряна: проекта в менеджере задач с id `{id}` нет
lint.pair_closed: в менеджере задач закрыт, в хранилище нет
lint.unpaired_counts: в хранилище {vault}, в менеджере задач {backend}
lint.clean: Дублей id, ссылок на несуществующие проекты, заметок в корне и потерянных пар нет.
