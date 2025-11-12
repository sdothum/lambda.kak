# kakoune-lambda

## lambda calculus

```
if-else %{ [ .. ] } %{
	..
} %{
	..
}

if %{ [ .. ] } %{
	..
}
```

## user-mode manager

```
addm %{ <group> [<sortkey>] : map global <user-mode> <key> <command> -docstring <string> }

setm %{ <user-mode> [: <group>] }

gapm %{ <user-mode> [[1|2|3] | <separator>] }
set-option global gapm_width <int>
```



