default:
	rm -rf build
	mkdir -p build/web_modules
	cp ../../Work/ts-sdk/dist/index.umd.js build/web_modules/fission-sdk.js
	elm make src/Main.elm --output=build/application.js --debug
	cp src/Main.html build/index.html
	cp src/Main.js build/index.js
	devd ./build -p 8002
