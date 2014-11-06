---
title: Bash Prompt, проверенный временем
image: /assets/pretty-bash-prompt.jpg
---
Подозреваю, что многие меняли внешний вид строки приглашения
(так же переводится prompt, правильно?) в консоли много-много раз.

После долгих экспериментов я остановился на таком:

``` bash
# http://stackoverflow.com/a/1862762
function timer_start {
  timer=${timer:-$SECONDS}
}
function timer_stop {
  timer_show=$(($SECONDS - $timer))
  unset timer
}
trap 'timer_start' DEBUG
PROMPT_COMMAND=${PROMPT_COMMAND}timer_stop;

## http://railstips.org/blog/archives/2009/02/02/bedazzle-your-bash-prompt-with-git-info/
ref=$(git symbolic-ref HEAD 2> /dev/null) || exit
echo "["${ref#refs/heads/}"]"

PS1="\[\e[0;33m\]\w\[\e[0m\]{\${timer_show}}(\$(ruby -v | cut -d' ' -f2))\$(parse_git_branch)$ "
```

Данное приглашение состоит из текущей директории, времени запуска последней команды в секундах,
версии руби и текущей git-ветки. Версию руби и ветку я видел у многих, а время запуска последней
команды вживую не встречал. Однако это очень удобно. Допустим у вас в консоли что-то долго работало
(например восстановление дампа базы), узнав время выполнения этой операции, вы сможете
лучше запланировать время в будущем.

В собранном виде это выглядит так:

![](/assets/pretty-bash-prompt/ps.png)

Симпатично.
