export NODE_OPTIONS := "--no-warnings"


# Variables
# ---------

dist 				:= "build"
dist_css 		:= dist + "/application.css"
src 				:= "src"


# Tasks
# -----

@default: dev-build
	just dev-server & just watch


@dev-build: clean css-large elm-dev html js static


@dev-server:
	echo "🤵  Serving the app on http://localhost:8002"
	devd --all --notfound=index.html --port 8002 --quiet ./build


@install-deps:
	pnpm install


@production-build: clean css-large elm-production html css-small js minify-js static



# Parts
# -----

@clean:
	rm -rf {{dist}}


@css-large:
	echo "🖼  Generating Elm Tailwind Module and a giant CSS file"

	# Make a CSS build with all the Tailwind stuff
	# and generate the Elm module
	pnpx etc {{src}}/Css/Main.css \
		--config tailwind.config.js \
	  --elm-path {{src}}/Tailwind.elm \
	  --output {{dist_css}} \
		\
		--post-plugin-before postcss-import \
		--post-plugin-after postcss-custom-properties \
		\
		>/dev/null 2>&1


@css-small:
	echo "🖼  Generating a tiny CSS file based on the generated Elm app"

	# Make a minified & purged CSS build
	NODE_ENV=production pnpx etc {{src}}/Css/Main.css \
		--config tailwind.config.js \
	  --output {{dist_css}} \
		\
	  --purge-content {{dist}}/**/*.html \
	  --purge-content {{dist}}/application.js \
		\
		--post-plugin-before postcss-import \
		--post-plugin-after postcss-custom-properties


@elm-dev:
	echo "🦉  Compiling Elm application in development mode"
	elm make src/App/Main.elm --output={{dist}}/application.js # --debug


@elm-production:
	echo "🦉  Compiling Elm application in production mode"
	elm make src/App/Main.elm --output={{dist}}/application.js --optimize


@html:
	echo "⚗️  Copying HTML"
	cp {{src}}/Html/Main.html {{dist}}/index.html


@js:
	echo "🍿  Copying Javascript"
	mkdir -p {{dist}}/web_modules
	cp ./node_modules/fission-sdk/index.umd.js {{dist}}/web_modules/fission-sdk.js
	cp {{src}}/Javascript/Main.js {{dist}}/index.js


@minify-js:
	echo "🍿  Minifying Javascript"
	pnpx terser-dir \
		{{dist}} \
		--each --extension .js \
		--patterns "**/*.js, !**/*.min.js" \
		--pseparator ", " \
		--output {{dist}} \
		-- --compress --mangle


@static:
	echo "⚗️  Copying static files"
	cp -RT {{src}}/Favicons/ {{dist}}/
	cp -RT {{src}}/Manifests/ {{dist}}/



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
