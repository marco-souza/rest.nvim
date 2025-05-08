all: pr-ready


decrypt:
	echo "===> Decrypting" && gpg -d .env.gpg > .env

encrypt:
	echo "===> Encrypting" && gpg -c .env

fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=.stylua.toml

lint:
	echo "===> Linting"
	luacheck lua/ --globals vim

pr-ready: fmt lint
	echo "===> Preparring PR"
	git commit
