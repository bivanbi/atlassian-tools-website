.DEFAULT_GOAL := all
APP_NAME = crowd_helper
SRC = src/html
DOWNLOAD = download
TARGET = target

JQUERY_URL="https://code.jquery.com/jquery-3.5.1.slim.min.js"

BOOTSTRAP_ZIP_URL="https://github.com/twbs/bootstrap/releases/download/v4.6.0/bootstrap-4.6.0-dist.zip"
BOOTSTRAP_ZIP = $(DOWNLOAD)/bootstrap.zip

CLIPART_REPO_URL="https://github.com/bivanbi/atlassian-tools-clipart.git"
CLIPART_REPO = $(DOWNLOAD)/clipart
CLIPART_VERSION= v2.0.0

JQUERY_URL="https://code.jquery.com/jquery-3.5.1.slim.min.js"

VENDOR = $(TARGET)/vendor

JQUERY_DIR=$(VENDOR)/jquery
JQUERY_JS = $(JQUERY_DIR)/jquery.slim.min.js

BOOTSTRAP_DIR = $(VENDOR)/bootstrap
BOOTSTRAP_CSS = $(BOOTSTRAP_DIR)/bootstrap.min.css
BOOTSTRAP_JS = $(BOOTSTRAP_DIR)/bootstrap.bundle.min.js

IMAGE_DIR = $(TARGET)/image
FAVICON = $(TARGET)/favicon.ico
APP_ICON = $(IMAGE_DIR)/$(APP_NAME).svg

all: $(TARGET) bootstrap clipart

.PHONY: clipart
clipart:  $(FAVICON) $(APP_ICON)

.PHONY: bootstrap
bootstrap: $(BOOTSTRAP_CSS) $(BOOTSTRAP_JS) $(JQUERY_JS) 


$(BOOTSTRAP_ZIP):
	mkdir -p $(DOWNLOAD)
	curl -sfL "$(BOOTSTRAP_ZIP_URL)" -o $(BOOTSTRAP_ZIP)

$(CLIPART_REPO):
	mkdir -p $(DOWNLOAD)
	git clone "$(CLIPART_REPO_URL)" $(CLIPART_REPO)
	git -C $(CLIPART_REPO) checkout $(CLIPART_VERSION)

$(TARGET):
	mkdir -p $(TARGET)
	(cd $(SRC) ; tar cf - --exclude="image" --exclude="vendor" . ) | (cd $(TARGET) ; tar xfBp -)

$(JQUERY_JS): $(TARGET)
	mkdir -p $(JQUERY_DIR)
	curl -sf "$(JQUERY_URL)" -o $(JQUERY_JS)

$(BOOTSTRAP_CSS): $(TARGET) $(BOOTSTRAP_ZIP)
	unzip -u $(BOOTSTRAP_ZIP) -d $(DOWNLOAD)/
	mkdir -p $(BOOTSTRAP_DIR)
	cp $(DOWNLOAD)/bootstrap*dist/css/bootstrap.min.css $(BOOTSTRAP_CSS)

$(BOOTSTRAP_JS): $(TARGET) $(BOOTSTRAP_ZIP)
	unzip -u $(BOOTSTRAP_ZIP) -d $(DOWNLOAD)/
	mkdir -p $(BOOTSTRAP_DIR)
	cp $(DOWNLOAD)/bootstrap*dist/js/bootstrap.bundle.min.js $(BOOTSTRAP_JS)

$(FAVICON): $(TARGET) $(CLIPART_REPO)
	$(DOWNLOAD)/clipart/build_images.sh
	cp $(DOWNLOAD)/clipart/target/$(APP_NAME)/favicon.ico $(FAVICON)

$(APP_ICON): $(TARGET) $(CLIPART_REPO)
	mkdir -p $(IMAGE_DIR)
	cp --no-preserve timestamps $(DOWNLOAD)/clipart/target/$(APP_NAME)/$(APP_NAME)-favicon.svg $(APP_ICON)

clean:
	rm -rf $(TARGET) $(DOWNLOAD)
