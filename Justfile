export NODE_OPTIONS := "--no-warnings"


# Variables
# ---------

dist 						:= "build"
dist_css 				:= dist + "/application.css"
src 						:= "src"
workbox_config 	:= "workbox.config.cjs"


# Tasks
# -----

@default: dev-build
	just dev-server # & just watch


@dev-build: clean css-large elm-dev html js-dev static service-worker


@dev-server:
	echo "🤵  Serving the app on http://localhost:8002"
	simple-http-server --port 8002 --try-file build/index.html --cors --index --nocache --silent -- build


@install-deps:
	npm install
	mkdir -p web_modules
	cp -r node_modules/webnative/dist/ ./web_modules/webnative/


@production-build: clean css-large elm-production html css-small js-production static service-worker-production



# Parts
# -----

@clean:
	rm -rf {{dist}}


@css-large:
	echo "🖼  Generating Elm Tailwind Module and a giant CSS file"

	# Make a CSS build with all the Tailwind stuff
	# and generate the Elm module
	npx elm-tailwind-css {{src}}/Css/Main.css \
		--config tailwind.config.js \
	  --elm-path {{src}}/Etcetera/Tailwind.elm \
	  --output {{dist_css}} \
		\
		--post-plugin-before postcss-import \
		--post-plugin-after postcss-custom-properties


@css-small:
	echo "🖼  Generating a tiny CSS file based on the generated Elm app"

	# Make a minified & purged CSS build
	NODE_ENV=production npx elm-tailwind-css {{src}}/Css/Main.css \
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


@js-dev:
	echo "🍿  Copying & Compiling Javascript in development mode"
	cp -rf web_modules {{dist}}/
	cp {{src}}/Javascript/Main.js {{dist}}/index.js


@js-production:
	echo "🍿  Copying & Compiling Javascript in production mode"
	cp -rf web_modules {{dist}}/
	cp {{src}}/Javascript/Main.js {{dist}}/index.js

	npx terser-dir \
		{{dist}} \
		--each --extension .js \
		--pattern "**/*.js, !**/*.min.js" \
		--pseparator ", " \
		--output {{dist}} \
		-- --compress --mangle


@service-worker:
	echo "🍿  Generating service worker"
	NODE_ENV=development npx workbox generateSW {{workbox_config}}


@service-worker-production:
	echo "🍿  Generating service worker"
	NODE_ENV=production npx workbox generateSW {{workbox_config}}


@static:
	echo "⚗️  Copying static files"
	cp {{src}}/Favicons/* {{dist}}/
	cp {{src}}/Manifests/* {{dist}}/



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
	watchexec -p -w {{src}} -e js -- just js-dev


@watch-html:
	watchexec -p -w {{src}} -e html -- just html
