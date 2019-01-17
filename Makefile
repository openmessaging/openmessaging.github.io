BUNDLE := bundle
JEKYLL := $(BUNDLE) exec jekyll

setup:
	gem install bundler \
		--no-document \
		--no-ri
	NOKOGIRI_USE_SYSTEM_LIBRARIES=true $(BUNDLE) install \
		--path vendor/bundle

build:
	$(JEKYLL) build

serve:
	$(JEKYLL) serve \
		--livereload
