dist 				:= "build"
dist_css 		:= dist + "/application.css"
src 				:= "src"


# Tasks
# -----

@default: dev-build
	just dev-server & just watch


@dev-build: clean css-large elm-dev html js


@dev-server:
	devd --all --notfound=index.html --port 8002 ./build


@install-deps:
	pnpm install


@minify-js:
	pnpx terser-dir \
		{{dist}} \
		--each --extension .js \
		--patterns "**/*.js, !**/*.min.js" \
		--pseparator ", " \
		--output {{dist}} \
		-- --compress --mangle


@production-build: clean css-large elm-production html css-small js minify-js



# Parts
# -----

@clean:
	rm -rf {{dist}}


@css-large:
	# Make a CSS build with all the Tailwind stuff
	# and generate the Elm module
	pnpx etc {{src}}/Main.css \
		--config tailwind.config.js \
	  --elm-path {{src}}/Tailwind.elm \
	  --output {{dist_css}} \
		\
		--post-plugin-before postcss-import \
		--post-plugin-after postcss-custom-properties


@css-small:
	# Make a minified & purged CSS build
	NODE_ENV=production pnpx etc {{src}}/Main.css \
		--config tailwind.config.js \
	  --output {{dist_css}} \
		\
	  --purge-content {{dist}}/**/*.html \
	  --purge-content {{dist}}/application.js \
		\
		--post-plugin-before postcss-import \
		--post-plugin-after postcss-custom-properties


@elm-dev:
	elm make src/Main.elm --output={{dist}}/application.js # --debug


@elm-production:
	elm make src/Main.elm --output={{dist}}/application.js --optimize


@html:
	cp {{src}}/Main.html {{dist}}/index.html


@js:
	mkdir -p {{dist}}/web_modules
	cp ./node_modules/fission-sdk/index.umd.js {{dist}}/web_modules/fission-sdk.js
	cp {{src}}/Main.js {{dist}}/index.js



# Watch
# -----

@watch:
	echo "👀  Watching for changes"
	just watch-css & \
	just watch-elm & \
	just watch-html & \
	just watch-js


@watch-css:
	watchexec -p -w . -f "**/*.css" -f "*/tailwind.config.js" -i {{dist}} -- just css-large


@watch-elm:
	watchexec -p -w {{src}} -e elm -- just elm-dev


@watch-js:
	watchexec -p -w {{src}} -e js -- just js


@watch-html:
	watchexec -p -w {{src}} -e html -- just html
