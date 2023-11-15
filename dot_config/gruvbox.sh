#! /bin/sh

# Gruvbox color scheme, shell variables.

dark0_hard='1d/20/21'
dark0='28/28/28'
dark0_soft='32/30/2f'
dark1='3c/38/36'
dark2='50/49/45'
dark3='66/5c/54'
dark4='7c/6f/64'
gray_245='92/83/74'
gray_244='92/83/74'
light0_hard='f9/f5/d7'
light0='fb/f1/c7'
light0_soft='f2/e5/bc'
light1='eb/db/b2'
light2='d5/c4/a1'
light3='bd/ae/93'
light4='a8/99/84'
bright_red='fb/49/34'
bright_green='b8/bb/26'
bright_yellow='fa/bd/2f'
bright_blue='83/a5/98'
bright_purple='d3/86/9b'
bright_aqua='8e/c0/7c'
bright_orange='fe/80/19'
neutral_red='cc/24/1d'
neutral_green='98/97/1a'
neutral_yellow='d7/99/21'
neutral_blue='45/85/88'
neutral_purple='b1/62/86'
neutral_aqua='68/9d/6a'
neutral_orange='d6/5d/0e'
faded_red='9d/00/06'
faded_green='79/74/0e'
faded_yellow='b5/76/14'
faded_blue='07/66/78'
faded_purple='8f/3f/71'
faded_aqua='42/7b/58'
faded_orange='af/3a/03'

if [ -n "$TMUX" ]; then
  # Tell tmux to pass the escape sequences through
  # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
  put_template() { printf '\033Ptmux;\033\033]4;%d;rgb:%s\033\033\\\033\\' $@; }
  put_template_var() { printf '\033Ptmux;\033\033]%d;rgb:%s\033\033\\\033\\' $@; }
  put_template_custom() { printf '\033Ptmux;\033\033]%s%s\033\033\\\033\\' $@; }
elif [ "${TERM%%[-.]*}" = "screen" ]; then
  # GNU screen (screen, screen-256color, screen-256color-bce)
  put_template() { printf '\033P\033]4;%d;rgb:%s\007\033\\' $@; }
  put_template_var() { printf '\033P\033]%d;rgb:%s\007\033\\' $@; }
  put_template_custom() { printf '\033P\033]%s%s\007\033\\' $@; }
elif [ "${TERM%%-*}" = "linux" ]; then
  put_template() { [ $1 -lt 16 ] && printf "\e]P%x%s" $1 $(echo $2 | sed 's/\///g'); }
  put_template_var() { true; }
  put_template_custom() { true; }
else
  put_template() { printf '\033]4;%d;rgb:%s\033\\' $@; }
  put_template_var() { printf '\033]%d;rgb:%s\033\\' $@; }
  put_template_custom() { printf '\033]%s%s\033\\' $@; }
fi

put_template 0 $dark0
put_template 235 $dark0
put_template 237 $dark1
put_template 239 $dark2
put_template 241 $dark3
put_template 243 $dark4
put_template 8 $gray_245
put_template 245 $gray_245

put_template 229 $light0
put_template 15 $light1
put_template 223 $light1
put_template 250 $light2
put_template 248 $light3
put_template 7 $light4
put_template 246 $light4

put_template 1 $neutral_red
put_template 124 $neutral_red
put_template 2 $neutral_green
put_template 106 $neutral_green
put_template 3 $neutral_yellow
put_template 172 $neutral_yellow
put_template 4 $neutral_blue
put_template 66 $neutral_blue
put_template 5 $neutral_purple
put_template 132 $neutral_purple
put_template 6 $neutral_aqua
put_template 72 $neutral_aqua
put_template 166 $neutral_orange

put_template 9 $bright_red
put_template 167 $bright_red
put_template 10 $bright_green
put_template 142 $bright_green
put_template 11 $bright_yellow
put_template 214 $bright_yellow
put_template 12 $bright_blue
put_template 109 $bright_blue
put_template 13 $bright_purple
put_template 175 $bright_purple
put_template 14 $bright_aqua
put_template 108 $bright_aqua
put_template 208 $bright_orange

put_template_var 10 $light1  # Foreground.
put_template_var 11 $dark0  # Background.

unset -f put_template
unset -f put_template_var
unset -f put_template_custom
unset dark0_hard
unset dark0
unset dark0_soft
unset dark1
unset dark2
unset dark3
unset dark4
unset gray_245
unset gray_244
unset light0_hard
unset light0
unset light0_soft
unset light1
unset light2
unset light3
unset light4
unset bright_red
unset bright_green
unset bright_yellow
unset bright_blue
unset bright_purple
unset bright_aqua
unset bright_orange
unset neutral_red
unset neutral_green
unset neutral_yellow
unset neutral_blue
unset neutral_purple
unset neutral_aqua
unset neutral_orange
unset faded_red
unset faded_green
unset faded_yellow
unset faded_blue
unset faded_purple
unset faded_aqua
unset faded_orange
