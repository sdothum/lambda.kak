# sdothum - 2016 (c) wtfpl

# Kakoune
# ══════════════════════════════════════════════════════════════════════════════

# Lambda calculus (block) control structures
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# simplifying "try %{ .. } catch %{ .. }" to "evaluate-commands -verbatim %arg{1} %arg{2} %arg{3}"
# where %arg{1} is "%sh{ test .. && echo .. || echo .. }"
# further refactored to "%{ test .. }" by the define-command with %arg{1} as $1

# ................................................................. if-then-else

# if-else %{ condition } %{ then } %{ else }
define-command -hidden if-else -params 3 %{ evaluate-commands -verbatim %sh{ eval $1 && echo then || echo else } %arg{2} %arg{3} }
define-command -hidden then    -params 2 %{ evaluate-commands %arg{1} }
define-command -hidden else    -params 2 %{ evaluate-commands %arg{2} }

# ...................................................................... if-then

# if %{ condition } %{ then }
define-command -hidden if -params 2 %{ if-else %arg{1} %arg{2} %{ nop } }

# User-mode order manager
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# .................................................................... Queue map

declare-option str usermodes ''

# addm %{ <group> [<sortkey>] : map global <user-mode> <key> <command> -docstring <string> }
define-command -hidden addm -params 1 %{
	set-option global usermodes "%sh{ echo ""$kak_opt_usermodes\n$(echo $1 | cut -d: -f2- | cut -d' ' -f4 )$1"" }"
}

# ................................................................. Activate map

# setm %{ <user-mode> [: <group>] }
define-command -hidden setm -params 1 %{
	evaluate-commands %sh{
		M=$(echo ${1%%:*})
		G=$(echo ${1#*:})
		[ "$M" = "$G" ] && unset G
		echo "$kak_opt_usermodes" | grep "^$M $G" | sort | cut -d: -f2-
	}
}

# ................................................... Insert user-mode separator

declare-option int gapm_width 32  # default separator ruler length

# gapm %{ <user-mode> [[1|2|3] | <separator>] }  # WHERE: up to 3 separators [+-=] within a single user-mode, default '+'
define-command -hidden gapm -params 1 %{
	evaluate-commands %sh{
		docstring() { for i in $(seq 1 $kak_opt_gapm_width) ;do printf "${F:-⠀}" ;done; [ -z "$F" ] && echo "$K\n⠀" || echo "$K"; }  # NOTE: U+2800 (braille blank) to prevent kak space char trimming

		set -- $1  # <user-mode> [1 | 2 | 3 | <separator>]
		# NOTE: multiple separators within a single user-mode list must map unique keys and docstrings (to display as separate lines)
		case "$2" in
			'' ) K=· ;;         # U+00b7 default
			1  ) K=· ;;         # U+00b7 of 3 available utf-8 center dot characters
			2  ) K=‧ ;;         # U+2027
			3  ) K=ꞏ ;;         # U+a78f
			*  ) K=$2; F=$2 ;;  # non-blank (visual) separator NOTE: limited to glyphs not represented by kak "<named>" character
		esac
		echo "map global $1 '$K' ': nop<ret>' -docstring '$(docstring)'"
	}
}

# kak: filetype=kak
